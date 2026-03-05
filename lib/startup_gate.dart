import 'dart:async';
import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/auth_page.dart';
import 'auth/email_verification_page.dart';
import 'auth/reset_password_page.dart';
import 'config/supabase_config.dart';
import 'consentimento_page.dart';
import 'escala/database/daos/med_list_dao.dart';
import 'escala/providers/blocked_day_provider.dart';
import 'escala/providers/note_provider.dart';
import 'escala/providers/patient_provider.dart';
import 'escala/providers/recurrence_provider.dart';
import 'escala/providers/report_provider.dart';
import 'escala/providers/shift_provider.dart';
import 'escala/services/archive_service.dart';
import 'escala/services/supabase_sync_service.dart';
import 'escala/services/widget_service.dart';
import 'home.dart';
import 'medicamento_unificado/lista_medicamentos_model.dart';
import 'storage_manager.dart';
import 'services/fcm_service.dart';
import 'services/user_access_service.dart';
import 'services/billing_service.dart';
import 'widgets/paywall_screen.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late Future<bool> _consentFuture;
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  String? _lastAccessUserId;
  bool _isPasswordRecoveryMode = false;
  bool _hadSession = false;
  bool _authWaitTimeout = false;

  double _syncProgress = 0.0;
  String _syncStatusText = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _consentFuture = _loadConsent();
    _appLinks = AppLinks();
    _initDeepLinks();
    if (kIsWeb) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && !_authWaitTimeout) {
          setState(() => _authWaitTimeout = true);
        }
      });
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _handleIncomingUri(uri);
      }
    } catch (_) {
      // Ignora erros de deep link para nao travar o app.
    }

    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleIncomingUri(uri);
      },
      onError: (_) {},
    );
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    try {
      final redirectTo = SupabaseConfig.authRedirectUrl;
      if (redirectTo == null || redirectTo.trim().isEmpty) return;
      final expected = Uri.parse(redirectTo);
      if (expected.scheme.isNotEmpty && uri.scheme != expected.scheme) return;
      if (expected.host.isNotEmpty && uri.host != expected.host) return;
      
      // Verifica se é um link de recuperação de senha pelo fragment ou query
      final fragment = uri.fragment;
      final isRecovery = fragment.contains('type=recovery') || 
                         uri.queryParameters['type'] == 'recovery';
      
      debugPrint('Deep link recebido: $uri');
      debugPrint('É link de recuperação: $isRecovery');
      
      // Se for recuperação, marca a flag ANTES de processar a sessão
      if (isRecovery && mounted) {
        setState(() {
          _isPasswordRecoveryMode = true;
        });
      }
      
      final response = await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Sessão obtida: ${response.session.user.email}');
      
      // Se for recuperação de senha, força o setState para mostrar a página
      if (isRecovery && mounted) {
        setState(() {
          _isPasswordRecoveryMode = true;
        });
      }
    } catch (e) {
      debugPrint('Erro ao processar deep link: $e');
      // Falha silenciosa, o usuario pode tentar novamente.
    }
  }

  Future<bool> _loadConsent() async {
    await StorageManager.instance.initialize();
    return StorageManager.instance.getBool('termoAceito');
  }

  void _refreshConsent() {
    setState(() {
      _consentFuture = _loadConsent();
    });
  }

  void _refreshDataProviders() {
    final ctx = context;
    if (ctx.mounted) {
      _ensureLocalDataThenLoad(ctx);
    }
  }

  void _updateSyncStatus(double progress, String text) {
    if (mounted) {
      setState(() {
        _syncProgress = progress;
        _syncStatusText = text;
      });
    }
  }

  Future<void> _ensureLocalDataThenLoad(BuildContext ctx) async {
    setState(() => _isSyncing = true);
    _updateSyncStatus(0.0, 'Verificando dados...');

    if (!ctx.mounted) return;

    await _migrateMedDataFromPrefs();

    if (!ctx.mounted) return;

    _updateSyncStatus(0.20, 'Carregando plantões...');
    try {
      final shiftProv = ctx.read<ShiftProvider>();
      await shiftProv.loadShifts();
      ctx.read<BlockedDayProvider>().reload();
    } catch (e) {
      debugPrint('Erro ao carregar providers: $e');
    }

    if (!ctx.mounted) return;

    _updateSyncStatus(0.35, 'Carregando recorrências...');
    try {
      await ctx.read<RecurrenceProvider>().load();
    } catch (e) {
      debugPrint('Erro ao carregar recorrências: $e');
    }

    WidgetService.setProviders(
      shiftProvider: ctx.read<ShiftProvider>(),
      recurrenceProvider: ctx.read<RecurrenceProvider>(),
      blockedDayProvider: ctx.read<BlockedDayProvider>(),
    );
    WidgetService.scheduleUpdate();

    if (!ctx.mounted) return;

    _updateSyncStatus(0.50, 'Carregando relatórios...');
    try {
      final reportProv = ctx.read<ReportProvider>();
      await reportProv.loadReports();
    } catch (e) {
      debugPrint('Erro ao carregar relatórios: $e');
    }

    if (!ctx.mounted) return;

    _updateSyncStatus(0.65, 'Verificando arquivamento...');
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'local';
      final archive = ArchiveService(
        shiftProvider: ctx.read<ShiftProvider>(),
        recurrenceProvider: ctx.read<RecurrenceProvider>(),
        reportProvider: ctx.read<ReportProvider>(),
        blockedDayProvider: ctx.read<BlockedDayProvider>(),
        userId: userId,
      );
      await archive.checkAndRun();
    } catch (e) {
      debugPrint('Erro no arquivamento: $e');
    }

    if (!ctx.mounted) return;

    _updateSyncStatus(0.75, 'Carregando anotações...');
    try {
      await ctx.read<NoteProvider>().reload();
      await ctx.read<PatientProvider>().reload();
    } catch (e) {
      debugPrint('Erro ao carregar anotações: $e');
    }

    if (!ctx.mounted) return;

    _updateSyncStatus(0.85, 'Sincronizando dados...');
    try {
      final syncService = SupabaseSyncService();
      if (syncService.isAvailable) {
        await syncService.pullAll(
          shiftProvider: ctx.read<ShiftProvider>(),
          recurrenceProvider: ctx.read<RecurrenceProvider>(),
          reportProvider: ctx.read<ReportProvider>(),
          blockedDayProvider: ctx.read<BlockedDayProvider>(),
          noteProvider: ctx.read<NoteProvider>(),
          patientProvider: ctx.read<PatientProvider>(),
        );
        await syncService.pushPendingChanges();
      }
    } catch (e) {
      debugPrint('Erro no sync escala: $e');
    }

    if (!ctx.mounted) return;

    _updateSyncStatus(1.0, '');
    if (mounted) setState(() => _isSyncing = false);
  }

  /// One-time migration: move listas from SharedPreferences to SQLite.
  Future<void> _migrateMedDataFromPrefs() async {
    try {
      await StorageManager.instance.initialize();
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      final alreadyMigrated =
          StorageManager.instance.getBool('med_data_migrated_to_sqlite');
      if (alreadyMigrated) return;

      final medListDao = MedListDao();
      final now = DateTime.now();

      final listasRaw = StorageManager.instance
          .getString('listas_medicamentos_custom', defaultValue: '[]');
      try {
        final list = jsonDecode(listasRaw) as List<dynamic>? ?? [];
        for (final item in list) {
          final old = ListaMedicamentosCustom.fromJson(
              item as Map<String, dynamic>);
          final model = ListaMedicamentosCustom(
            id: old.id,
            nome: old.nome,
            medicamentoIds: old.medicamentoIds,
            createdAt: now,
            updatedAt: now,
          );
          await medListDao.insert(model.toDbRow(uid));
        }
      } catch (e) {
        debugPrint('Erro ao migrar listas: $e');
      }

      await StorageManager.instance.remove('listas_medicamentos_custom');
      await StorageManager.instance.remove('medicamentos_favoritos');
      await StorageManager.instance.remove('farmacoteca_favoritos');
      await StorageManager.instance.setBool('med_data_migrated_to_sqlite', true);

      debugPrint('Migração de medicamentos para SQLite concluída.');
    } catch (e) {
      debugPrint('Erro na migração de medicamentos: $e');
    }
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2848),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/imagen/splash_logo_small_1024.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 40),
            if (_isSyncing) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _syncProgress > 0 ? _syncProgress : null,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4DD0E1),
                    ),
                  ),
                ),
              ),
              if (_syncStatusText.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _syncStatusText,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMissingSupabase() {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_outlined,
                  size: 56, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Supabase nao configurado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                'Defina SUPABASE_URL e SUPABASE_ANON_KEY no seu .env.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  void _registerAccess(Session? session) {
    if (session == null) {
      _lastAccessUserId = null;
      return;
    }

    final userId = session.user.id;
    if (_lastAccessUserId == userId) return;
    _lastAccessUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UserAccessService.registerAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return _buildMissingSupabase();
    }

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final authState = snapshot.data;
        final session =
            authState?.session ?? Supabase.instance.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting &&
            session == null) {
          if (kIsWeb && _authWaitTimeout) {
            return const AuthPage();
          }
          return _buildLoading();
        }

        // Verifica se é modo de recuperação de senha (via evento ou flag)
        if (authState?.event == AuthChangeEvent.passwordRecovery || 
            _isPasswordRecoveryMode) {
          return ResetPasswordPage(
            onPasswordChanged: () {
              if (mounted) {
                setState(() {
                  _isPasswordRecoveryMode = false;
                });
              }
            },
          );
        }

        if (session == null) {
          final wasKicked = _hadSession;
          _hadSession = false;
          _registerAccess(null);
          if (wasKicked) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final messenger = ScaffoldMessenger.maybeOf(context);
              messenger?.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sessão encerrada — login detectado em outro dispositivo',
                  ),
                  duration: Duration(seconds: 5),
                ),
              );
            });
          }
          return const AuthPage();
        }

        // Verifica se o email foi confirmado
        final user = session.user;
        final emailConfirmed = user.emailConfirmedAt != null;

        if (!emailConfirmed) {
          return EmailVerificationPage(
            email: user.email ?? '',
            onVerified: () {
              // Força refresh do estado de autenticação
              setState(() {});
            },
            onBackToLogin: () async {
              try {
                await Supabase.instance.client.auth.signOut();
              } catch (_) {}
              if (mounted) {
                setState(() {});
              }
            },
          );
        }

        _hadSession = true;
        _registerAccess(session);

        return FutureBuilder<bool>(
          future: _consentFuture,
          builder: (context, consentSnapshot) {
            if (consentSnapshot.connectionState != ConnectionState.done) {
              return _buildLoading();
            }

            final termoAceito = consentSnapshot.data ?? false;
            if (!termoAceito) {
              return _SessionReadyWrapper(
                onSessionReady: _refreshDataProviders,
                child: ConsentimentoPage(onAccepted: _refreshConsent),
              );
            }
            return _SessionReadyWrapper(
              onSessionReady: _refreshDataProviders,
              child: _BillingGate(
                isSyncing: _isSyncing,
                syncProgress: _syncProgress,
                syncStatusText: _syncStatusText,
                onLogout: () async {
                  try { await Supabase.instance.client.auth.signOut(); } catch (_) {}
                  if (mounted) setState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// Dispara o refresh dos providers quando a sessão está pronta.
/// Corrige o bug em que hospitais (e outros dados) não apareciam porque
/// load* era chamado antes da autenticação estar disponível.
class _SessionReadyWrapper extends StatefulWidget {
  final VoidCallback onSessionReady;
  final Widget child;

  const _SessionReadyWrapper({
    required this.onSessionReady,
    required this.child,
  });

  @override
  State<_SessionReadyWrapper> createState() => _SessionReadyWrapperState();
}

class _SessionReadyWrapperState extends State<_SessionReadyWrapper> {
  bool _didRefresh = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didRefresh) {
      _didRefresh = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onSessionReady();
          // Initialize FCM after session is ready (registers token)
          if (!kIsWeb) {
            FcmService.instance.initialize().catchError((e) {
              debugPrint('FCM init error: $e');
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Verifica a flag billing_enabled no Supabase.
/// Se ativa, exibe PaywallScreen; senão, exibe HomePage normalmente.
class _BillingGate extends StatefulWidget {
  final VoidCallback onLogout;
  final bool isSyncing;
  final double syncProgress;
  final String syncStatusText;

  const _BillingGate({
    required this.onLogout,
    this.isSyncing = false,
    this.syncProgress = 0.0,
    this.syncStatusText = '',
  });

  @override
  State<_BillingGate> createState() => _BillingGateState();
}

class _BillingGateState extends State<_BillingGate> {
  bool _loading = true;
  bool _billingActive = false;

  @override
  void initState() {
    super.initState();
    _checkBilling();
  }

  Future<void> _checkBilling() async {
    final enabled = await BillingService.instance.fetchBillingEnabled();
    if (mounted) {
      setState(() {
        _billingActive = enabled;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLoading = _loading || widget.isSyncing;

    if (showLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A2848),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/imagen/splash_logo_small_1024.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 40),
              if (widget.isSyncing) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: widget.syncProgress > 0 ? widget.syncProgress : null,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4DD0E1),
                      ),
                    ),
                  ),
                ),
                if (widget.syncStatusText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.syncStatusText,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    }

    if (_billingActive) {
      return PaywallScreen(onLogout: widget.onLogout);
    }

    return const HomePage();
  }
}
