import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static const String defaultAuthRedirectUrl = 'guidedose://login-callback';

  static String get url {
    final value = _readEnv('SUPABASE_URL');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }

    final openAiUrl = _readEnv('OPENAI_API_URL');
    if (openAiUrl != null && openAiUrl.trim().isNotEmpty) {
      final derived = _deriveSupabaseUrl(openAiUrl.trim());
      if (derived != null) {
        return derived;
      }
    }

    return const String.fromEnvironment('SUPABASE_URL');
  }

  static String get anonKey {
    final value = _readEnv('SUPABASE_ANON_KEY');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return const String.fromEnvironment('SUPABASE_ANON_KEY');
  }

  static bool get isConfigured => url.trim().isNotEmpty && anonKey.trim().isNotEmpty;

  static String? get authRedirectUrl {
    final value = _readEnv('SUPABASE_AUTH_REDIRECT_URL');
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    final envValue = const String.fromEnvironment('SUPABASE_AUTH_REDIRECT_URL');
    if (envValue.trim().isNotEmpty) {
      return envValue.trim();
    }
    return defaultAuthRedirectUrl;
  }

  static String? _readEnv(String key) {
    try {
      if (!dotenv.isInitialized) return null;
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  static String? _deriveSupabaseUrl(String raw) {
    try {
      final uri = Uri.parse(raw);
      if (!uri.hasScheme || uri.host.isEmpty) return null;
      if (!uri.host.endsWith('supabase.co')) return null;
      return '${uri.scheme}://${uri.host}';
    } catch (_) {
      return null;
    }
  }
}
