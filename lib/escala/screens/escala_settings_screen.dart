import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/shift_provider.dart';
import '../services/calendar_sync_service.dart';
import '../utils/constants.dart';
import 'blocked_days_list_screen.dart';

class EscalaSettingsScreen extends StatefulWidget {
  const EscalaSettingsScreen({super.key});

  @override
  State<EscalaSettingsScreen> createState() => _EscalaSettingsScreenState();
}

class _EscalaSettingsScreenState extends State<EscalaSettingsScreen> {
  final CalendarSyncService _calendarSync = CalendarSyncService();
  late bool _calendarEnabled;

  @override
  void initState() {
    super.initState();
    _calendarEnabled = _calendarSync.isEnabled;
  }

  Future<void> _onCalendarToggle(bool value) async {
    if (value) {
      final granted = await _calendarSync.requestPermission();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de calendário negada'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      await _calendarSync.setEnabled(true);
      setState(() => _calendarEnabled = true);

      if (mounted) {
        final shiftProv = context.read<ShiftProvider>();
        _calendarSync.syncAllShifts(shiftProv.shifts);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronizando plantões com o calendário...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      await _calendarSync.setEnabled(false);
      setState(() => _calendarEnabled = false);
      _calendarSync.removeAllEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eventos removidos do calendário'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: const Text(AppStrings.settingsScreenTitle),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SettingsTile(
                  icon: Icons.block_outlined,
                  title: AppStrings.settingsBlockedDays,
                  subtitle: AppStrings.addBlockTitle,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BlockedDaysListScreen(),
                      ),
                    );
                  },
                ),
                _CalendarSyncTile(
                  enabled: _calendarEnabled,
                  onChanged: _onCalendarToggle,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dados locais com backup na nuvem',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}

class _CalendarSyncTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _CalendarSyncTile({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SwitchListTile(
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.calendar_month_outlined,
            color: theme.colorScheme.primary, size: 22),
      ),
      title: const Text(
        'Sincronizar com calendário',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'Adicionar plantões ao calendário do dispositivo',
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      value: enabled,
      onChanged: onChanged,
    );
  }
}
