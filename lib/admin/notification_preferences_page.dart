import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/error_messages.dart';

/// User-facing screen to manage their notification preferences.
class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  bool _loading = true;
  bool _pushEnabled = true;
  bool _eveShiftEnabled = true;
  bool _blockedDayEnabled = true;
  bool _broadcastEnabled = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      final res = await Supabase.instance.client
          .from('notification_preferences')
          .select()
          .eq('user_id', uid)
          .maybeSingle();

      if (res != null) {
        _pushEnabled = res['push_enabled'] ?? true;
        _eveShiftEnabled = res['eve_shift_enabled'] ?? true;
        _blockedDayEnabled = res['blocked_day_enabled'] ?? true;
        _broadcastEnabled = res['broadcast_enabled'] ?? true;
      }
    } catch (e) {
      debugPrint('Load notification prefs error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;

      await Supabase.instance.client
          .from('notification_preferences')
          .upsert({
        'user_id': uid,
        'push_enabled': _pushEnabled,
        'eve_shift_enabled': _eveShiftEnabled,
        'blocked_day_enabled': _blockedDayEnabled,
        'broadcast_enabled': _broadcastEnabled,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferências salvas.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErroAmigavel(e)), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Notificações push'),
                          subtitle: const Text(
                              'Receber notificações no celular'),
                          value: _pushEnabled,
                          onChanged: (v) =>
                              setState(() => _pushEnabled = v),
                          activeColor: AppColors.primary,
                          secondary: const Icon(Icons.notifications_active),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Lembrete na véspera'),
                          subtitle: const Text(
                              'Aviso de plantão no dia seguinte'),
                          value: _eveShiftEnabled,
                          onChanged: _pushEnabled
                              ? (v) =>
                                  setState(() => _eveShiftEnabled = v)
                              : null,
                          activeColor: AppColors.primary,
                          secondary: const Icon(Icons.alarm),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Conflito dia bloqueado'),
                          subtitle: const Text(
                              'Aviso de plantão em dia bloqueado'),
                          value: _blockedDayEnabled,
                          onChanged: _pushEnabled
                              ? (v) =>
                                  setState(() => _blockedDayEnabled = v)
                              : null,
                          activeColor: AppColors.primary,
                          secondary: const Icon(Icons.block),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Mensagens broadcast'),
                          subtitle: const Text(
                              'Avisos gerais do GuideDose'),
                          value: _broadcastEnabled,
                          onChanged: _pushEnabled
                              ? (v) =>
                                  setState(() => _broadcastEnabled = v)
                              : null,
                          activeColor: AppColors.primary,
                          secondary: const Icon(Icons.campaign),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_saving
                        ? 'Salvando…'
                        : 'Salvar preferências'),
                  ),
                ],
              ),
            ),
    );
  }
}
