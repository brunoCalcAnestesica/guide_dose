import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/credentials_service.dart';
import '../theme/app_colors.dart';
import '../utils/error_messages.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  /// Carrega as credenciais salvas, se existirem
  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await CredentialsService.instance.getCredentials();
      final rememberMe = await CredentialsService.instance.isRememberMeEnabled();
      
      if (mounted) {
        setState(() {
          _rememberMe = rememberMe;
          if (credentials != null) {
            _emailController.text = credentials.email;
            _passwordController.text = credentials.password;
          }
        });
      }
    } catch (_) {
      // Se falhar ao carregar credenciais, continua sem elas
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Atualiza o user_metadata com o locale do dispositivo (idioma/país) para exibição no painel admin.
  Future<void> _updateUserLocaleFromDevice() async {
    try {
      final locale = Localizations.maybeLocaleOf(context);
      final lang = locale?.languageCode ?? 'pt';
      final country = locale?.countryCode ?? 'BR';
      final localeStr = '${lang}_$country';
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'locale': localeStr}),
      );
    } catch (_) {
      // Não bloqueia o fluxo; país no painel pode ficar em branco.
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final redirectTo = SupabaseConfig.authRedirectUrl;

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        await _updateUserLocaleFromDevice();
        try {
          await Supabase.instance.client.auth.signOut(
            scope: SignOutScope.others,
          );
        } catch (_) {
          // Se falhar, mantem a sessao atual e segue.
        }
        
        // Salva ou limpa as credenciais baseado na opção "Lembrar-me"
        if (_rememberMe) {
          await CredentialsService.instance.saveCredentials(
            email: email,
            password: password,
          );
        } else {
          await CredentialsService.instance.clearCredentials();
        }
        
        _showMessage('Login realizado com sucesso.');
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: redirectTo,
        );

        final user = response.user;
        final session =
            response.session ?? Supabase.instance.client.auth.currentSession;

        if (user != null && session != null) {
          try {
            final profileData = <String, dynamic>{
              'id': user.id,
              'email': user.email,
            };
            await Supabase.instance.client.from('profiles').upsert(profileData);
          } catch (_) {
            // Nao bloqueia o fluxo caso o perfil nao seja criado.
          }
          await _updateUserLocaleFromDevice();
        }

        // Verifica se o email precisa ser confirmado
        final needsEmailConfirmation = user?.emailConfirmedAt == null;

        if (needsEmailConfirmation) {
          // O StartupGate vai detectar a sessão e mostrar a página de verificação
          _showMessage(
              'Cadastro realizado! Enviamos um link de confirmação para seu e-mail.');
        } else {
          _showMessage('Cadastro realizado com sucesso!');
        }
      }
    } on AuthException catch (e) {
      _showMessage(mensagemErroAmigavel(e));
    } catch (e) {
      _showMessage(mensagemErroAmigavel(e));
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Informe um e-mail valido para recuperar a senha.');
      return;
    }

    try {
      // Usa o deep link do app para redefinição de senha
      final redirectUrl = SupabaseConfig.authRedirectUrl;
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      _showMessage('Enviamos um link de recuperacao para seu e-mail.');
    } on AuthException catch (e) {
      _showMessage(mensagemErroAmigavel(e));
    } catch (e) {
      _showMessage(mensagemErroAmigavel(e));
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe seu e-mail.';
    }
    if (!value.contains('@')) {
      return 'E-mail invalido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha.';
    }
    if (value.length < 6) {
      return 'Use ao menos 6 caracteres.';
    }
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (_isLogin) return null;
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/imagen/auth_background.png',
                  fit: BoxFit.cover,
                ),
                Align(
                  alignment: const Alignment(0, -0.8),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '+ ',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const TextSpan(
                          text: 'Guide Dose',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.top,
                          child: Text(
                            '®',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          blurRadius: 30,
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.white,
                          blurRadius: 20,
                          offset: Offset(0, 0),
                        ),
                        Shadow(
                          color: Colors.white,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4FA),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF0EEF6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Senha',
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
                              filled: true,
                              fillColor: const Color(0xFFF0EEF6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.2,
                                ),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          if (!_isLogin) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirmController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar senha',
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: const Color(0xFFF0EEF6),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              validator: _validateConfirmation,
                            ),
                          ],
                          if (_isLogin) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _rememberMe = !_rememberMe;
                                    });
                                  },
                                  child: const Text(
                                    'Lembrar minha senha',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 0,
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
                                  : Text(
                                      _isLogin ? 'Entrar' : 'Criar conta',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_isLogin)
                            TextButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              child: Text(
                                'Esqueceu a senha?',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                side: BorderSide(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                              child: Text(
                                _isLogin ? 'Criar conta' : 'Ja tenho conta',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
