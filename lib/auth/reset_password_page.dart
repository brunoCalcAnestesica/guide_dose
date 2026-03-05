import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final VoidCallback? onPasswordChanged;
  
  const ResetPasswordPage({super.key, this.onPasswordChanged});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final password = _passwordController.text;

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );
      _showMessage('Senha atualizada com sucesso!');
      // Aguarda um momento para o usuário ver a mensagem
      await Future.delayed(const Duration(milliseconds: 800));
      widget.onPasswordChanged?.call();
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      if (_isConnectionError(e)) {
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint('📶 AVISO: Conexão com o servidor instável ou indisponível');
        debugPrint('   Por favor, verifique sua conexão com a internet.');
        debugPrint('   Se o problema persistir, tente novamente em alguns minutos.');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        _showMessage('Conexão instável. Verifique sua internet e tente novamente.');
      } else {
        _showMessage('Nao foi possivel atualizar a senha.');
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua nova senha.';
    }
    if (value.length < 6) {
      return 'Use ao menos 6 caracteres.';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha.';
    }
    if (value != _passwordController.text) {
      return 'As senhas nao conferem.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 8,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_reset,
                      size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Criar nova senha',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digite sua nova senha abaixo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Nova senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscurePassword,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: _validateConfirmation,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Salvar nova senha',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
