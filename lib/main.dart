import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:home_widget/home_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'startup_gate.dart';
import 'theme/app_theme.dart';
import 'consentimento_page.dart';
import 'bulario_page.dart';
import 'home.dart';
import 'config/supabase_config.dart';
import 'escala/providers/blocked_day_provider.dart';
import 'escala/providers/note_provider.dart';
import 'escala/providers/patient_provider.dart';
import 'escala/providers/recurrence_provider.dart';
import 'escala/providers/report_provider.dart';
import 'escala/providers/shift_provider.dart';
import 'escala/screens/day_detail_screen.dart';
import 'escala/screens/notes_and_patients_screen.dart';
import 'escala/screens/shift_divider_screen.dart';
import 'escala/services/repass_reminder_notification_service.dart';
import 'escala/services/widget_service.dart';
import 'medical_ai_screen.dart';
import 'storage_manager.dart';

class WidgetDeepLink {
  static DateTime? pendingDate;
  static String? pendingRoute;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env', isOptional: true);
    await dotenv.load(fileName: 'cahves_api_openia.env', isOptional: true);
  } catch (_) {}

  final sentryDsn = dotenv.env['SENTRY_DSN'] ?? const String.fromEnvironment('SENTRY_DSN');

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn.isNotEmpty ? sentryDsn : '';
      options.tracesSampleRate = 0.2;
      options.environment = const String.fromEnvironment('ENV', defaultValue: 'production');
    },
    appRunner: () async {
      await StorageManager.instance.initialize();

      if (SupabaseConfig.isConfigured) {
        try {
          await Supabase.initialize(
            url: SupabaseConfig.url,
            anonKey: SupabaseConfig.anonKey,
          );
        } catch (e) {
          debugPrint('Erro ao inicializar Supabase: $e');
          Sentry.captureException(e);
        }
      } else {
        debugPrint('Supabase nao configurado: SUPABASE_URL/ANON_KEY ausentes.');
      }

      // Initialize Firebase (FCM push notifications) – mobile only
      if (!kIsWeb) {
        try {
          await Firebase.initializeApp();
          debugPrint('Firebase initialized');
        } catch (e) {
          debugPrint('Firebase init skipped (not configured): $e');
        }
      }

      await initializeDateFormatting('pt_BR', null);

      await WidgetService.initialize();
      WidgetService.updateWidgetData();

      final navigatorKey = GlobalKey<NavigatorState>();
      runApp(GuideDoseApp(navigatorKey: navigatorKey));
    },
  );
}

class GuideDoseApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const GuideDoseApp({super.key, required this.navigatorKey});

  @override
  State<GuideDoseApp> createState() => _GuideDoseAppState();
}

class _GuideDoseAppState extends State<GuideDoseApp>
    with WidgetsBindingObserver {
  DateTime? _lastResumeRefresh;
  static const _refreshCooldown = Duration(minutes: 2);
  StreamSubscription? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RepassReminderNotificationService.initialize(widget.navigatorKey);
    });
    _initWidgetClickListener();
  }

  void _initWidgetClickListener() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) _handleWidgetUri(uri, coldStart: true);
    });
    _widgetClickSub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _handleWidgetUri(uri, coldStart: false);
    });
  }

  void _handleWidgetUri(Uri uri, {bool coldStart = false}) {
    final host = uri.host;

    if (host == 'day') {
      final dateStr = uri.queryParameters['date'];
      if (dateStr == null) return;
      final date = DateTime.tryParse(dateStr);
      if (date == null) return;
      WidgetDeepLink.pendingDate = date;
    } else if (host == 'divider' || host == 'ai' || host == 'notes') {
      WidgetDeepLink.pendingRoute = host;
    } else {
      return;
    }

    if (!coldStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateFromDeepLink();
      });
    }
  }

  void _navigateFromDeepLink() {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;

    final pendingDate = WidgetDeepLink.pendingDate;
    if (pendingDate != null) {
      WidgetDeepLink.pendingDate = null;
      Navigator.of(ctx).push(
        MaterialPageRoute(builder: (_) => DayDetailScreen(date: pendingDate)),
      );
      return;
    }

    final route = WidgetDeepLink.pendingRoute;
    if (route != null) {
      WidgetDeepLink.pendingRoute = null;
      final Widget screen;
      switch (route) {
        case 'divider':
          screen = const ShiftDividerScreen();
        case 'ai':
          screen = const MedicalAIScreen();
        case 'notes':
          screen = const NotesAndPatientsScreen();
        default:
          return;
      }
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  void dispose() {
    _widgetClickSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastResumeRefresh != null &&
          now.difference(_lastResumeRefresh!) < _refreshCooldown) {
        return;
      }
      _lastResumeRefresh = now;
      _refreshProviders();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _flushSyncToCloud();
    }
  }

  void _flushSyncToCloud() {
    // placeholder for future backend sync
  }

  void _refreshProviders() {
    final ctx = widget.navigatorKey.currentContext;
    if (ctx == null) return;
    ctx.read<ShiftProvider>().syncChanges();
    ctx.read<BlockedDayProvider>().reload();
    WidgetService.setProviders(
      shiftProvider: ctx.read<ShiftProvider>(),
      recurrenceProvider: ctx.read<RecurrenceProvider>(),
      blockedDayProvider: ctx.read<BlockedDayProvider>(),
    );
    WidgetService.scheduleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShiftProvider()..loadShifts()),
        ChangeNotifierProvider(create: (_) => RecurrenceProvider()..load()),
        ChangeNotifierProvider(create: (_) => BlockedDayProvider()..load()),
        ChangeNotifierProvider(create: (_) => NoteProvider()..load()),
        ChangeNotifierProvider(create: (_) => PatientProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
      navigatorKey: widget.navigatorKey,
      navigatorObservers: [SentryNavigatorObserver()],
      title: 'Guide Dose ®',
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', ''),
        Locale('en', ''),
        Locale('es', ''),
        Locale('zh', ''),
      ],
      debugShowCheckedModeBanner: false,
      home: const StartupGate(),
      routes: {
        '/consentimento': (context) => ConsentimentoPage(
              onAccepted: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const StartupGate()),
                );
              },
            ),
        '/home': (context) => const HomePage(),
        '/bulario': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return BularioPage(principioAtivo: args ?? 'adrenalina');
        },
      },
    )
    );
  }
}
