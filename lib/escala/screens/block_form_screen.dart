import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Conteúdo do formulário de bloqueio, reutilizável na mesma página ou em tela própria.
class BlockFormContent extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback? onSaved;

  const BlockFormContent({super.key, this.initialDate, this.onSaved});

  @override
  State<BlockFormContent> createState() => _BlockFormContentState();
}

class _BlockFormContentState extends State<BlockFormContent> {
  static const _modeSingle = 'single';
  static const _modeRange = 'range';

  late DateTime _selectedDate;
  late DateTime _dateStart;
  late DateTime _dateEnd;
  String _mode = _modeSingle;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate != null
        ? DateTime(
            widget.initialDate!.year,
            widget.initialDate!.month,
            widget.initialDate!.day,
          )
        : DateTime.now();
    _selectedDate = initial;
    _dateStart = initial;
    _dateEnd = initial;
    _labelController = TextEditingController(text: AppStrings.blockLabelFeriado);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(DateTime initial, void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month - 3, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month + 13, 0),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _pickStartDate() async {
    await _pickDate(_dateStart, (picked) {
      _dateStart = picked;
      if (_dateEnd.isBefore(_dateStart)) _dateEnd = _dateStart;
    });
  }

  Future<void> _pickEndDate() async {
    await _pickDate(_dateEnd, (picked) {
      _dateEnd = picked;
      if (_dateStart.isAfter(_dateEnd)) _dateStart = _dateEnd;
    });
  }

  Future<void> _save() async {
    final label = _labelController.text.trim();
    final effectiveLabel = label.isEmpty ? AppStrings.blockLabelFeriado : label;
    final start = _mode == _modeSingle
        ? DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
        : DateTime(_dateStart.year, _dateStart.month, _dateStart.day);
    final end = _mode == _modeSingle
        ? start
        : DateTime(_dateEnd.year, _dateEnd.month, _dateEnd.day);
    if (end.isBefore(start)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data final deve ser igual ou posterior à data inicial.')),
        );
      }
      return;
    }
    final shiftProvider = context.read<ShiftProvider>();
    final shiftsInRange = shiftProvider.getByDateRange(start, end);
    if (shiftsInRange.isNotEmpty && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(AppStrings.blockWarningShiftsTitle),
          content: const Text(AppStrings.blockWarningShiftsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(AppStrings.blockAnyway),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;
    }
    try {
      if (_mode == _modeSingle) {
        await context.read<BlockedDayProvider>().add(_selectedDate, effectiveLabel);
      } else {
        await context.read<BlockedDayProvider>().addRange(start, end, effectiveLabel);
      }
      if (mounted) widget.onSaved?.call();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: _modeSingle,
                label: Text(AppStrings.blockModeSingle),
                icon: Icon(Icons.today, size: 18),
              ),
              ButtonSegment(
                value: _modeRange,
                label: Text(AppStrings.blockModeRange),
                icon: Icon(Icons.date_range, size: 18),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (selection) {
              setState(() {
                _mode = selection.first;
                if (_mode == _modeRange) {
                  _dateStart = _selectedDate;
                  _dateEnd = _selectedDate;
                }
              });
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 16),
          if (_mode == _modeSingle) ...[
            InkWell(
              onTap: () => _pickDate(_selectedDate, (picked) => setState(() => _selectedDate = picked)),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppStrings.date,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  AppFormatters.formatDate(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ] else ...[
            InkWell(
              onTap: _pickStartDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppStrings.filterDateStart,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  AppFormatters.formatDate(_dateStart),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickEndDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: AppStrings.filterDateEnd,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.event),
                ),
                child: Text(
                  AppFormatters.formatDate(_dateEnd),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: AppStrings.blockLabelHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.block),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text(AppStrings.save),
          ),
        ],
      );
  }
}

class BlockFormScreen extends StatefulWidget {
  final DateTime? initialDate;

  const BlockFormScreen({super.key, this.initialDate});

  @override
  State<BlockFormScreen> createState() => _BlockFormScreenState();
}

class _BlockFormScreenState extends State<BlockFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.addBlockTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlockFormContent(
          initialDate: widget.initialDate,
          onSaved: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
