import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../storage_manager.dart';

/// Informação retornada quando há atualização disponível.
class UpdateInfo {
  const UpdateInfo({
    required this.updateAvailable,
    required this.currentVersion,
    this.latestVersion,
    this.storeUrl,
    this.message,
  });

  final bool updateAvailable;
  final String currentVersion;
  final String? latestVersion;
  final String? storeUrl;
  final String? message;
}

/// URLs das lojas (atualize quando publicar em outras regiões).
class StoreUrls {
  static const String ios =
      'https://apps.apple.com/br/app/med-guide-dose/id6453359266';
  // Android ainda não disponível na loja.
  static const String? android = null;
}

/// Serviço que verifica se a versão instalada é a mais recente e retorna
/// dados para exibir o aviso de atualização (com link para a loja).
class VersionCheckService {
  VersionCheckService._();
  static final VersionCheckService instance = VersionCheckService._();

  static const _storageKeyLastPrompt = 'version_check_last_prompt_ts';
  static const _promptCooldownHours = 24;

  /// Compara duas versões semânticas (ex: "3.6.1" ou "3.6.1+2").
  /// Retorna < 0 se [current] < [latest], 0 se iguais, > 0 se current > latest.
  int compareVersions(String current, String latest) {
    final c = _parseVersion(current);
    final l = _parseVersion(latest);
    for (var i = 0; i < 3; i++) {
      final a = i < c.length ? c[i] : 0;
      final b = i < l.length ? l[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  List<int> _parseVersion(String v) {
    final part = v.split(RegExp(r'\+')).first.trim();
    return part
        .split('.')
        .map((e) => int.tryParse(e.trim()) ?? 0)
        .toList();
  }

  /// Retorna a versão mais recente configurada no Supabase para a plataforma atual.
  /// Chaves esperadas na tabela app_config: latest_ios_version, latest_android_version.
  Future<String?> _fetchLatestVersionFromSupabase() async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      final key = Platform.isIOS ? 'latest_ios_version' : 'latest_android_version';
      final res = await Supabase.instance.client
          .from('app_config')
          .select('value')
          .eq('key', key)
          .maybeSingle();
      final value = res?['value'] as String?;
      return value?.trim();
    } catch (_) {
      return null;
    }
  }

  /// Verifica se deve exibir o aviso de atualização (respeitando cooldown).
  Future<bool> shouldShowUpdatePrompt() async {
    try {
      final lastTs = StorageManager.instance.getInt(_storageKeyLastPrompt);
      if (lastTs > 0) {
        final diffHours =
            (DateTime.now().millisecondsSinceEpoch - lastTs) / (1000 * 60 * 60);
        if (diffHours < _promptCooldownHours) return false;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  /// Marca que o aviso foi exibido (para não repetir no cooldown).
  Future<void> markUpdatePromptShown() async {
    await StorageManager.instance.setInt(
      _storageKeyLastPrompt,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Obtém a versão atual do app e, se houver configuração no Supabase,
  /// compara com a versão mais recente. Retorna [UpdateInfo] com indicação
  /// de atualização disponível e link da loja (iOS; Android ainda não disponível).
  Future<UpdateInfo> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    final latest = await _fetchLatestVersionFromSupabase();

    if (latest == null || latest.isEmpty) {
      return UpdateInfo(
        updateAvailable: false,
        currentVersion: currentVersion,
      );
    }

    final needUpdate = compareVersions(currentVersion, latest) < 0;
    final storeUrl = Platform.isIOS ? StoreUrls.ios : StoreUrls.android;

    return UpdateInfo(
      updateAvailable: needUpdate,
      currentVersion: currentVersion,
      latestVersion: latest,
      storeUrl: storeUrl,
      message: needUpdate
          ? (Platform.isIOS
              ? 'Uma nova versão ($latest) está disponível na App Store.'
              : 'Uma nova versão ($latest) está disponível. Em breve na Play Store.')
          : null,
    );
  }
}
