import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/version_check_service.dart';

/// Diálogo que informa sobre nova versão e oferece link para a loja (App Store / Play Store).
class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({
    super.key,
    required this.info,
    this.onDismiss,
  });

  final UpdateInfo info;
  final VoidCallback? onDismiss;

  static Future<void> showIfNeeded(BuildContext context) async {
    final shouldShow =
        await VersionCheckService.instance.shouldShowUpdatePrompt();
    if (!shouldShow) return;

    final updateInfo =
        await VersionCheckService.instance.checkForUpdate();
    if (!updateInfo.updateAvailable || !context.mounted) return;

    await VersionCheckService.instance.markUpdatePromptShown();

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => UpdateAvailableDialog(
        info: updateInfo,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _openStore() async {
    final url = info.storeUrl;
    if (url == null || url.isEmpty) {
      if (onDismiss != null) onDismiss!();
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasStoreLink = info.storeUrl != null && info.storeUrl!.isNotEmpty;

    return AlertDialog(
      title: const Text('Nova versão disponível'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (info.message != null)
              Text(info.message!, style: const TextStyle(fontSize: 16)),
            if (info.latestVersion != null) ...[
              const SizedBox(height: 12),
              Text(
                'Sua versão: ${info.currentVersion} → Nova: ${info.latestVersion}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (!hasStoreLink) ...[
              const SizedBox(height: 12),
              Text(
                'O app em breve estará disponível na Play Store.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text('Depois'),
        ),
        if (hasStoreLink)
          FilledButton(
            onPressed: _openStore,
            child: Text(Platform.isIOS ? 'Abrir na App Store' : 'Abrir na Play Store'),
          )
        else
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
      ],
    );
  }
}
