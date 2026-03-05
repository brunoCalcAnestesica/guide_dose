import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuração para conexão com a OpenAI.
/// 
/// Suporta duas formas de uso:
/// 1. Direto: usando OPENAI_API_KEY (não recomendado para produção)
/// 2. Via Proxy: usando Supabase Edge Function (recomendado)
class OpenAIConfig {
  /// Chave da API da OpenAI (opcional se usar proxy)
  static String get apiKey {
    final value = _readEnv('OPENAI_API_KEY');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('OPENAI_API_KEY');
  }

  /// URL da API (OpenAI direta ou proxy Supabase)
  static String get apiUrl {
    final value = _readEnv('OPENAI_API_URL');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment(
      'OPENAI_API_URL',
      // IMPORTANTE: Substitua pela URL do seu proxy Supabase
      defaultValue: 'https://SEU-PROJETO.supabase.co/functions/v1/openai-proxy',
    );
  }

  /// Modelo da OpenAI a ser usado
  static String get model {
    final value = _readEnv('OPENAI_MODEL');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment(
      'OPENAI_MODEL',
      defaultValue: 'gpt-4.1',
    );
  }

  /// Número de WhatsApp para contato (opcional)
  static String get sofiaWhatsAppNumber {
    final value = _readEnv('SOFIA_WHATSAPP_NUMBER');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment(
      'SOFIA_WHATSAPP_NUMBER',
      defaultValue: '',
    );
  }

  /// Chave anon do Supabase (necessária para usar o proxy)
  static String get supabaseAnonKey {
    final value = _readEnv('SUPABASE_ANON_KEY');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  /// Lê variável do arquivo .env
  static String? _readEnv(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  /// Verifica se está usando proxy (não é API direta da OpenAI)
  static bool get usesProxy => !apiUrl.contains('api.openai.com');
  
  /// Verifica se tem chave da API configurada
  static bool get hasApiKey => apiKey.trim().isNotEmpty;
  
  /// Verifica se tem chave do proxy configurada
  static bool get hasProxyKey => supabaseAnonKey.trim().isNotEmpty;
}
