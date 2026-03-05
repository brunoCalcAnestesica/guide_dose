import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final VoidCallback? onVerified;
  final VoidCallback? onBackToLogin;

  const EmailVerificationPage({
    super.key,
    required this.email,
    this.onVerified,
    this.onBackToLogin,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool _isResending = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    // Verifica periodicamente se o email foi confirmado
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    try {
      // Atualiza a sessão para obter o status mais recente
      await Supabase.instance.client.auth.refreshSession();
      final user = Supabase.instance.client.auth.currentUser;

      if (user != null && user.emailConfirmedAt != null) {
        _checkTimer?.cancel();
        if (mounted) {
          widget.onVerified?.call();
        }
      }
    } catch (_) {
      // Ignora erros de verificação
    }
  }

  Future<void> _resendConfirmationEmail() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );

      if (mounted) {
        _showMessage('Email de confirmação reenviado com sucesso!');
        _startCooldown();
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showMessage(e.message);
      }
    } catch (e) {
      if (mounted) {
        if (_isConnectionError(e)) {
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          debugPrint('📶 AVISO: Conexão com o servidor instável ou indisponível');
          debugPrint('   Por favor, verifique sua conexão com a internet.');
          debugPrint('   Se o problema persistir, tente novamente em alguns minutos.');
          debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          _showMessage('Conexão instável. Verifique sua internet e tente novamente.');
        } else {
          _showMessage('Não foi possível reenviar o email. Tente novamente.');
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleBackToLogin() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // Ignora erros de logout
    }
    widget.onBackToLogin?.call();
  }

  /// Verifica se o erro é relacionado a problemas de conexão/rede
  bool _isConnectionError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Verifica SocketException diretamente (apenas em plataformas não-web)
    if (!kIsWeb && error is SocketException) {
      return true;
    }
    
    // Verifica padrões comuns de erros de conexão na mensagem
    return errorString.contains('socketexception') ||
           errorString.contains('failed host lookup') ||
           errorString.contains('connection refused') ||
           errorString.contains('connection timed out') ||
           errorString.contains('network is unreachable') ||
           errorString.contains('no address associated') ||
           errorString.contains('connection reset') ||
           errorString.contains('handshake') ||
           errorString.contains('clientexception');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Verifique seu e-mail',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enviamos um link de confirmação para:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.email,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Clique no link do e-mail para ativar sua conta. '
                        'Após a confirmação, você será redirecionado automaticamente.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Verificando...',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Não recebeu o e-mail?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canResend
                                ? AppColors.primary
                                : Colors.grey[400],
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed:
                              _canResend && !_isResending ? _resendConfirmationEmail : null,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            _canResend
                                ? 'Reenviar e-mail'
                                : 'Aguarde $_resendCooldown segundos',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          onPressed: _handleBackToLogin,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(
                            'Voltar para o login',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Verifique também a pasta de spam.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
