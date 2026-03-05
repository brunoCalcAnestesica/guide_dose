import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIConfig {
  static String get preciseModel {
    final value = _readEnvValue('OPENAI_MODEL_PRECISE');
    if (value.isNotEmpty) {
      return value;
    }
    final defined = const String.fromEnvironment('OPENAI_MODEL_PRECISE');
    if (defined.trim().isNotEmpty) {
      return defined.trim();
    }
    final legacyEnv = _readEnvValue('OPENAI_MODEL');
    if (legacyEnv.isNotEmpty) {
      return legacyEnv;
    }
    final legacyDefined = const String.fromEnvironment('OPENAI_MODEL');
    if (legacyDefined.trim().isNotEmpty) {
      return legacyDefined.trim();
    }
    return 'gpt-4.1-mini';
  }

  static String get completeModel {
    final value = _readEnvValue('OPENAI_MODEL_COMPLETE');
    if (value.isNotEmpty) {
      return value;
    }
    final defined = const String.fromEnvironment('OPENAI_MODEL_COMPLETE');
    if (defined.trim().isNotEmpty) {
      return defined.trim();
    }
    final legacyEnv = _readEnvValue('OPENAI_MODEL');
    if (legacyEnv.isNotEmpty) {
      return legacyEnv;
    }
    final legacyDefined = const String.fromEnvironment('OPENAI_MODEL');
    if (legacyDefined.trim().isNotEmpty) {
      return legacyDefined.trim();
    }
    return 'gpt-4.1';
  }

  static String get preciseFallbackModel {
    final value = _readEnvValue('OPENAI_MODEL_PRECISE_FALLBACK');
    if (value.isNotEmpty) {
      return value;
    }
    final defined = const String.fromEnvironment('OPENAI_MODEL_PRECISE_FALLBACK');
    if (defined.trim().isNotEmpty) {
      return defined.trim();
    }
    return 'gpt-4o-mini';
  }

  static String get apiKey {
    final value = _readEnv('OPENAI_API_KEY');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('OPENAI_API_KEY');
  }

  static String get apiUrl {
    final value = _readEnv('OPENAI_API_URL');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('OPENAI_API_URL', defaultValue: '');
  }

  /// URL da API OpenAI para fallback quando o proxy falhar.
  static const String directOpenAIUrl =
      'https://api.openai.com/v1/chat/completions';

  /// True quando está usando proxy e tem API key para chamar OpenAI direto.
  static bool get canFallbackToDirect => usesProxy && hasApiKey;

  static String get model => completeModel;

  static String get sofiaWhatsAppNumber {
    final value = _readEnv('SOFIA_WHATSAPP_NUMBER');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment(
      'SOFIA_WHATSAPP_NUMBER',
      defaultValue: '+5595981240016',
    );
  }

  static String get supabaseAnonKey {
    final value = _readEnv('SUPABASE_ANON_KEY');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  static String? _readEnv(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  static String _readEnvValue(String key) {
    final value = _readEnv(key);
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return '';
  }

  static bool get usesProxy => !apiUrl.contains('api.openai.com');
  static bool get hasApiKey => apiKey.trim().isNotEmpty;
  static bool get hasProxyKey => supabaseAnonKey.trim().isNotEmpty;

  /// Timeout em segundos para requisições à API (default 90).
  static int get timeoutSeconds {
    final value = _readEnv('OPENAI_TIMEOUT_SECONDS');
    if (value != null && value.trim().isNotEmpty) {
      final n = int.tryParse(value.trim());
      if (n != null && n > 0) return n;
    }
    return 90;
  }
}
