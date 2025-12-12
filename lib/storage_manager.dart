import 'package:shared_preferences/shared_preferences.dart';

/// Gerenciador de armazenamento usando SharedPreferences
/// Persiste dados localmente no dispositivo
class StorageManager {
  static StorageManager? _instance;
  static StorageManager get instance => _instance ??= StorageManager._();
  
  StorageManager._();
  
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  /// Inicializa o gerenciador de armazenamento
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    } catch (e) {
      // Se houver erro, continua sem inicializar
      _initialized = false;
    }
  }
  
  /// Obtém um valor booleano
  bool getBool(String key, {bool defaultValue = false}) {
    if (!_initialized || _prefs == null) return defaultValue;
    return _prefs!.getBool(key) ?? defaultValue;
  }
  
  /// Define um valor booleano
  Future<void> setBool(String key, bool value) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.setBool(key, value);
    }
  }
  
  /// Obtém uma string
  String getString(String key, {String defaultValue = ''}) {
    if (!_initialized || _prefs == null) return defaultValue;
    return _prefs!.getString(key) ?? defaultValue;
  }
  
  /// Define uma string
  Future<void> setString(String key, String value) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.setString(key, value);
    }
  }
  
  /// Obtém um número inteiro
  int getInt(String key, {int defaultValue = 0}) {
    if (!_initialized || _prefs == null) return defaultValue;
    return _prefs!.getInt(key) ?? defaultValue;
  }
  
  /// Define um número inteiro
  Future<void> setInt(String key, int value) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.setInt(key, value);
    }
  }
  
  /// Obtém um número decimal
  double getDouble(String key, {double defaultValue = 0.0}) {
    if (!_initialized || _prefs == null) return defaultValue;
    return _prefs!.getDouble(key) ?? defaultValue;
  }
  
  /// Define um número decimal
  Future<void> setDouble(String key, double value) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.setDouble(key, value);
    }
  }
  
  /// Obtém uma lista de strings
  List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    if (!_initialized || _prefs == null) return defaultValue;
    return _prefs!.getStringList(key) ?? defaultValue;
  }
  
  /// Define uma lista de strings
  Future<void> setStringList(String key, List<String> value) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.setStringList(key, value);
    }
  }
  
  /// Remove uma chave
  Future<void> remove(String key) async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.remove(key);
    }
  }
  
  /// Limpa todos os dados
  Future<void> clear() async {
    await initialize();
    if (_prefs != null) {
      await _prefs!.clear();
    }
  }
  
  /// Verifica se uma chave existe
  bool containsKey(String key) {
    if (!_initialized || _prefs == null) return false;
    return _prefs!.containsKey(key);
  }
  
  /// Obtém todas as chaves
  Set<String> getKeys() {
    if (!_initialized || _prefs == null) return {};
    return _prefs!.getKeys();
  }
}