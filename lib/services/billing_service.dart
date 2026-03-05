import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../storage_manager.dart';

/// Verifica se a cobrança está ativada no app_config do Supabase.
/// Quando ativada, usuários sem assinatura devem ver a tela de paywall.
class BillingService {
  BillingService._();
  static final BillingService instance = BillingService._();

  static const _billingKey = 'billing_enabled';
  static const _storageCache = 'billing_enabled_cached';

  bool _lastKnownValue = false;
  bool get isBillingEnabled => _lastKnownValue;

  /// Carrega o estado da cobrança do Supabase.
  /// Retorna true se billing_enabled == 'true'.
  /// Usa timeout de 10s para não travar o splash se a rede falhar.
  Future<bool> fetchBillingEnabled() async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      const timeout = Duration(seconds: 10);
      final res = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', _billingKey)
          .maybeSingle()
          .timeout(timeout, onTimeout: () {
        debugPrint('BillingService: timeout ao buscar billing_enabled');
        return null;
      });
      final value = (res?['value'] as String?)?.trim().toLowerCase() == 'true';
      _lastKnownValue = value;
      StorageManager.instance.setBool(_storageCache, value);
      return value;
    } catch (e) {
      debugPrint('BillingService: erro ao buscar billing_enabled: $e');
      _lastKnownValue = StorageManager.instance.getBool(_storageCache);
      return _lastKnownValue;
    }
  }

  /// Retorna o valor do cache local (rápido, sem rede).
  bool getCachedBillingEnabled() {
    _lastKnownValue = StorageManager.instance.getBool(_storageCache);
    return _lastKnownValue;
  }
}
