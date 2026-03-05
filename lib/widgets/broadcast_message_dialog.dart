import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../storage_manager.dart';

/// Exibe a mensagem enviada pelo admin (broadcast) se houver uma nova e ainda não mostrada.
class BroadcastMessageDialog {
  static const _storageKeyLastShown = 'last_shown_broadcast_updated_at';

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!SupabaseConfig.isConfigured) return;
    try {
      final client = Supabase.instance.client;
      final keys = ['broadcast_message', 'broadcast_title', 'broadcast_updated_at'];
      final res = await client
          .from('app_config')
          .select('key, value')
          .inFilter('key', keys);
      final Map<String, String> map = {
        for (final r in res)
          if (r['value'] != null) r['key'] as String: r['value'] as String,
      };

      final message = map['broadcast_message']?.trim();
      if (message == null || message.isEmpty) return;

      await StorageManager.instance.initialize();
      final lastShown = StorageManager.instance.getString(_storageKeyLastShown);
      final updatedAt = map['broadcast_updated_at'] ?? '';
      if (updatedAt == lastShown) return;

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: Text(map['broadcast_title']?.trim().isNotEmpty == true
              ? map['broadcast_title']!
              : 'Mensagem do GuideDose'),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      await StorageManager.instance.setString(_storageKeyLastShown, updatedAt);
    } catch (_) {
      // Falha silenciosa; não bloqueia o app.
    }
  }
}
