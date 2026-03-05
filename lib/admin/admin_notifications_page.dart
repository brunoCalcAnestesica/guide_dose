import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/error_messages.dart';

/// Admin panel for managing push notifications.
/// Only accessible to users with role = 'admin' in profiles.
class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações (Admin)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.6),
          tabs: const [
            Tab(icon: Icon(Icons.send), text: 'Enviar'),
            Tab(icon: Icon(Icons.campaign), text: 'Broadcast'),
            Tab(icon: Icon(Icons.schedule), text: 'Agendadas'),
            Tab(icon: Icon(Icons.history), text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SendPushTab(),
          _BroadcastTab(),
          _SchedulesTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

// ============================================================
// Tab 1: Send Push (sob demanda)
// ============================================================

class _SendPushTab extends StatefulWidget {
  const _SendPushTab();

  @override
  State<_SendPushTab> createState() => _SendPushTabState();
}

class _SendPushTabState extends State<_SendPushTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  String _targetType = 'all';
  final _userSearchCtrl = TextEditingController();
  List<Map<String, dynamic>> _selectedUsers = [];
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _linkCtrl.dispose();
    _userSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      dynamic target;
      if (_targetType == 'all') {
        target = 'all';
      } else if (_targetType == 'users' && _selectedUsers.isNotEmpty) {
        target = _selectedUsers.map((u) => u['id'] as String).toList();
      } else if (_targetType == 'user' && _selectedUsers.length == 1) {
        target = _selectedUsers.first['id'] as String;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selecione ao menos um destinatário.')),
          );
        }
        setState(() => _sending = false);
        return;
      }

      final session = Supabase.instance.client.auth.currentSession;
      final response = await Supabase.instance.client.functions.invoke(
        'send-push',
        body: {
          'target': target,
          'title': _titleCtrl.text.trim(),
          'body': _bodyCtrl.text.trim(),
          'link': _linkCtrl.text.trim().isEmpty
              ? null
              : _linkCtrl.text.trim(),
          'source': 'manual',
        },
        headers: {
          if (session != null)
            'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      if (!mounted) return;

      final data = response.data;
      final sent = data is Map ? data['sent'] ?? 0 : 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notificação enviada para $sent dispositivo(s).'),
          backgroundColor: Colors.green,
        ),
      );
      _titleCtrl.clear();
      _bodyCtrl.clear();
      _linkCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErroAmigavel(e)), backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) setState(() => _sending = false);
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().length < 2) return;
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name')
          .ilike('full_name', '%${query.trim()}%')
          .limit(10);
      if (!mounted) return;
      final results = (res as List).cast<Map<String, dynamic>>();
      if (results.isEmpty) return;

      final picked = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Selecionar usuário'),
          children: results
              .map(
                (u) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, u),
                  child: Text(u['full_name'] ?? u['id']),
                ),
              )
              .toList(),
        ),
      );
      if (picked != null) {
        setState(() {
          if (!_selectedUsers.any((u) => u['id'] == picked['id'])) {
            _selectedUsers.add(picked);
          }
          _userSearchCtrl.clear();
        });
      }
    } catch (e) {
      debugPrint('User search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text('Destinatário',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Todos')),
                ButtonSegment(value: 'users', label: Text('Escolher')),
              ],
              selected: {_targetType},
              onSelectionChanged: (v) =>
                  setState(() => _targetType = v.first),
            ),
            if (_targetType != 'all') ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _userSearchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por nome',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onFieldSubmitted: _searchUsers,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchUsers(_userSearchCtrl.text),
                  ),
                ],
              ),
              if (_selectedUsers.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  children: _selectedUsers
                      .map(
                        (u) => Chip(
                          label: Text(u['full_name'] ?? u['id']),
                          onDeleted: () => setState(
                              () => _selectedUsers.remove(u)),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(
                labelText: 'Corpo da notificação',
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Link ao tocar (opcional)',
                prefixIcon: Icon(Icons.link),
                hintText: 'guidedose://escala ou https://...',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_sending ? 'Enviando…' : 'Enviar notificação'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 2: Broadcast + Push
// ============================================================

class _BroadcastTab extends StatefulWidget {
  const _BroadcastTab();

  @override
  State<_BroadcastTab> createState() => _BroadcastTabState();
}

class _BroadcastTabState extends State<_BroadcastTab> {
  final _titleCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _alsoPush = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      final res = await Supabase.instance.client
          .from('app_config')
          .select('key, value')
          .inFilter('key', ['broadcast_title', 'broadcast_message']);
      for (final row in res) {
        if (row['key'] == 'broadcast_title') {
          _titleCtrl.text = row['value'] ?? '';
        }
        if (row['key'] == 'broadcast_message') {
          _msgCtrl.text = row['value'] ?? '';
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem obrigatória')),
      );
      return;
    }
    setState(() => _sending = true);

    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final client = Supabase.instance.client;

      for (final entry in {
        'broadcast_title': _titleCtrl.text.trim(),
        'broadcast_message': _msgCtrl.text.trim(),
        'broadcast_updated_at': now,
      }.entries) {
        await client.from('app_config').upsert(
          {'key': entry.key, 'value': entry.value},
          onConflict: 'key',
        );
      }

      if (_alsoPush) {
        final session = client.auth.currentSession;
        await client.functions.invoke(
          'send-push',
          body: {
            'target': 'all',
            'title': _titleCtrl.text.trim().isNotEmpty
                ? _titleCtrl.text.trim()
                : 'Mensagem do GuideDose',
            'body': _msgCtrl.text.trim(),
            'source': 'broadcast',
          },
          headers: {
            if (session != null)
              'Authorization': 'Bearer ${session.accessToken}',
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_alsoPush
                ? 'Broadcast salvo e push enviado!'
                : 'Broadcast salvo!'),
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

    if (mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Broadcast aparece como dialog ao abrir o app.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Título do broadcast',
              prefixIcon: Icon(Icons.title),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _msgCtrl,
            decoration: const InputDecoration(
              labelText: 'Mensagem',
              prefixIcon: Icon(Icons.message),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            title: const Text('Enviar também notificação push'),
            subtitle: const Text('Envia push para todos os dispositivos'),
            value: _alsoPush,
            onChanged: (v) => setState(() => _alsoPush = v),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _sending ? null : _save,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.campaign),
            label: Text(_sending ? 'Salvando…' : 'Salvar broadcast'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Tab 3: Schedules (agendadas)
// ============================================================

class _SchedulesTab extends StatefulWidget {
  const _SchedulesTab();

  @override
  State<_SchedulesTab> createState() => _SchedulesTabState();
}

class _SchedulesTabState extends State<_SchedulesTab> {
  List<Map<String, dynamic>> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client
          .from('push_schedules')
          .select()
          .order('scheduled_at', ascending: true);
      _schedules = (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Load schedules error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addSchedule() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const _ScheduleFormDialog(),
    );
    if (result == null) return;

    try {
      await Supabase.instance.client.from('push_schedules').insert(result);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagemErroAmigavel(e)), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleActive(int id, bool active) async {
    try {
      await Supabase.instance.client
          .from('push_schedules')
          .update({'is_active': active})
          .eq('id', id);
      _load();
    } catch (e) {
      debugPrint('Toggle schedule error: $e');
    }
  }

  Future<void> _delete(int id) async {
    try {
      await Supabase.instance.client
          .from('push_schedules')
          .delete()
          .eq('id', id);
      _load();
    } catch (e) {
      debugPrint('Delete schedule error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: FilledButton.icon(
            onPressed: _addSchedule,
            icon: const Icon(Icons.add),
            label: const Text('Nova notificação agendada'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ),
        Expanded(
          child: _schedules.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma notificação agendada',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: _schedules.length,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  itemBuilder: (ctx, i) {
                    final s = _schedules[i];
                    final active = s['is_active'] == true;
                    return Card(
                      child: ListTile(
                        title: Text(s['title'] ?? ''),
                        subtitle: Text(
                          '${s['target_type']} • ${s['scheduled_at']}'
                          '${s['recurrence'] != null ? ' • ${s['recurrence']}' : ''}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: active,
                              onChanged: (v) =>
                                  _toggleActive(s['id'] as int, v),
                              activeColor: AppColors.primary,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _delete(s['id'] as int),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ScheduleFormDialog extends StatefulWidget {
  const _ScheduleFormDialog();

  @override
  State<_ScheduleFormDialog> createState() => _ScheduleFormDialogState();
}

class _ScheduleFormDialogState extends State<_ScheduleFormDialog> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  String _targetType = 'all';
  String? _recurrence;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agendar notificação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bodyCtrl,
              decoration: const InputDecoration(labelText: 'Corpo'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _linkCtrl,
              decoration: const InputDecoration(
                  labelText: 'Link (opcional)'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _targetType,
              decoration: const InputDecoration(labelText: 'Destinatário'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
              ],
              onChanged: (v) => setState(() => _targetType = v ?? 'all'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data e hora'),
              subtitle: Text(
                '${_scheduledAt.day.toString().padLeft(2, '0')}'
                '/${_scheduledAt.month.toString().padLeft(2, '0')}'
                '/${_scheduledAt.year}'
                ' às ${_scheduledAt.hour.toString().padLeft(2, '0')}'
                ':${_scheduledAt.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _recurrence,
              decoration: const InputDecoration(labelText: 'Recorrência'),
              items: const [
                DropdownMenuItem(value: null, child: Text('Uma vez')),
                DropdownMenuItem(value: 'daily', child: Text('Diária')),
                DropdownMenuItem(value: 'weekly', child: Text('Semanal')),
                DropdownMenuItem(value: 'monthly', child: Text('Mensal')),
              ],
              onChanged: (v) => setState(() => _recurrence = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_titleCtrl.text.trim().isEmpty ||
                _bodyCtrl.text.trim().isEmpty) {
              return;
            }
            Navigator.pop(context, {
              'target_type': _targetType,
              'title': _titleCtrl.text.trim(),
              'body': _bodyCtrl.text.trim(),
              'link': _linkCtrl.text.trim().isEmpty
                  ? null
                  : _linkCtrl.text.trim(),
              'scheduled_at': _scheduledAt.toUtc().toIso8601String(),
              'recurrence': _recurrence,
              'is_active': true,
            });
          },
          child: const Text('Agendar'),
        ),
      ],
    );
  }
}

// ============================================================
// Tab 4: History
// ============================================================

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client
          .from('push_notifications')
          .select()
          .order('sent_at', ascending: false)
          .limit(50);
      _items = (res as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Load history error: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  String _formatSource(String? source) {
    switch (source) {
      case 'manual':
        return 'Manual';
      case 'broadcast':
        return 'Broadcast';
      case 'schedule':
        return 'Agendada';
      case 'auto_eve':
        return 'Auto (véspera)';
      case 'auto_blocked':
        return 'Auto (bloqueado)';
      default:
        return source ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma notificação enviada',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _loading = true);
        await _load();
      },
      child: ListView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemBuilder: (ctx, i) {
          final n = _items[i];
          return Card(
            child: ListTile(
              title: Text(n['title'] ?? ''),
              subtitle: Text(
                '${n['body'] ?? ''}\n'
                '${_formatSource(n['source'])} • ${n['target_type']} • '
                '${n['tokens_count'] ?? 0} dispositivo(s)',
              ),
              isThreeLine: true,
              trailing: Text(
                _formatDate(n['sent_at']),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '—';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}
