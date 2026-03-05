import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para armazenar credenciais de forma segura
/// Usa criptografia nativa do dispositivo para proteger os dados
class CredentialsService {
  static CredentialsService? _instance;
  static CredentialsService get instance => _instance ??= CredentialsService._();
  
  CredentialsService._();
  
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Chaves para armazenamento
  static const _keyEmail = 'saved_email';
  static const _keyPassword = 'saved_password';
  static const _keyRememberMe = 'remember_me';
  
  /// Salva as credenciais do usuário
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyRememberMe, value: 'true');
  }
  
  /// Obtém as credenciais salvas
  /// Retorna null se não houver credenciais salvas ou se "lembrar-me" estiver desativado
  Future<({String email, String password})?> getCredentials() async {
    final rememberMe = await _storage.read(key: _keyRememberMe);
    if (rememberMe != 'true') return null;
    
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    
    if (email == null || password == null) return null;
    if (email.isEmpty || password.isEmpty) return null;
    
    return (email: email, password: password);
  }
  
  /// Verifica se o usuário optou por lembrar as credenciais
  Future<bool> isRememberMeEnabled() async {
    final rememberMe = await _storage.read(key: _keyRememberMe);
    return rememberMe == 'true';
  }
  
  /// Remove as credenciais salvas
  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.write(key: _keyRememberMe, value: 'false');
  }
  
  /// Define apenas a opção "lembrar-me" sem alterar as credenciais
  Future<void> setRememberMe(bool value) async {
    if (!value) {
      await clearCredentials();
    } else {
      await _storage.write(key: _keyRememberMe, value: 'true');
    }
  }
}
