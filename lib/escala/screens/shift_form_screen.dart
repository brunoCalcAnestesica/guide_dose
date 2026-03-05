import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/recurrence_rule.dart';
import '../models/shift.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../services/archive_service.dart';
import '../providers/report_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/recurrence_picker.dart';
import 'block_form_screen.dart';

class ShiftFormScreen extends StatefulWidget {
  final Shift? shift;
  final DateTime? initialDate;
  /// Pre-fill fields without being in "edit" mode (used for editing a single
  /// occurrence of a recurring shift as a new standalone shift).
  final Shift? prefill;

  const ShiftFormScreen({super.key, this.shift, this.initialDate, this.prefill});

  @override
  State<ShiftFormScreen> createState() => _ShiftFormScreenState();
}

class _ShiftFormScreenState extends State<ShiftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  static const Map<String, List<TimeOfDay>> _defaultTimesByType = {
    'Diurno': [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 19, minute: 0)],
    'Noturno': [TimeOfDay(hour: 19, minute: 0), TimeOfDay(hour: 7, minute: 0)],
    '24h': [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 7, minute: 0)],
    'Manhã': [TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 13, minute: 0)],
    'Tarde': [TimeOfDay(hour: 13, minute: 0), TimeOfDay(hour: 19, minute: 0)],
    'Cinderela': [TimeOfDay(hour: 19, minute: 0), TimeOfDay(hour: 1, minute: 0)],
    'Procedimento': [TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 12, minute: 0)],
  };

  late TextEditingController _hospitalController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late TextEditingController _valueController;
  late TextEditingController _informationsController;
  late String _selectedType;
  late bool _isAllDay;
  late bool _isCompleted;
  late RecurrenceRule _recurrenceRule;

  String _eventType = 'shift';

  bool get isEditing => widget.shift != null;

  @override
  void initState() {
    super.initState();
    final src = widget.shift ?? widget.prefill;
    _hospitalController = TextEditingController(
      text: src?.hospitalName ?? '',
    );
    _selectedDate = src?.date ??
        widget.initialDate ??
        DateTime.now();
    _startTime = src != null
        ? _parseTimeOfDay(src.startTime)
        : const TimeOfDay(hour: 7, minute: 0);
    _endTime = src != null
        ? _parseTimeOfDay(src.endTime)
        : const TimeOfDay(hour: 19, minute: 0);
    _valueController = TextEditingController(
      text: src?.value.toStringAsFixed(2) ?? '',
    );
    _informationsController = TextEditingController(
      text: src?.informations ?? '',
    );
    _selectedType = src?.type ?? AppStrings.shiftTypes[0];
    _isAllDay = src?.isAllDay ?? false;
    _isCompleted = src?.isCompleted ?? false;
    _recurrenceRule = RecurrenceRule();
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _applyDefaultTimesForType(String type) {
    final defaults = _defaultTimesByType[type];
    if (defaults == null || defaults.length < 2) return;
    _startTime = defaults[0];
    _endTime = defaults[1];
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _valueController.dispose();
    _informationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editShift : AppStrings.addShift,
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: (!isEditing && _eventType == 'block')
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildEventTypeToggle(),
                const SizedBox(height: 16),
                BlockFormContent(
                  initialDate: _selectedDate,
                  onSaved: () => Navigator.of(context).pop(),
                ),
              ],
            )
          : Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            if (!isEditing) _buildEventTypeToggle(),
            if (!isEditing) const SizedBox(height: 16),
            _buildHospitalField(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: AppStrings.shiftType,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTipoIcon(),
                        if (_selectedType.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedType,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              selectedItemBuilder: (context) => AppStrings.shiftTypes
                  .map((type) => const SizedBox.shrink())
                  .toList(),
              items: AppStrings.shiftTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                    _applyDefaultTimesForType(value);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text(
                'Dia inteiro',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              secondary: const Icon(Icons.access_time),
              value: _isAllDay,
              onChanged: (value) {
                setState(() {
                  _isAllDay = value;
                  if (value) {
                    _startTime = const TimeOfDay(hour: 0, minute: 0);
                    _endTime = const TimeOfDay(hour: 23, minute: 59);
                  } else {
                    _applyDefaultTimesForType(_selectedType);
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (!_isAllDay) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildTimeField(AppStrings.startTime, _startTime, true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTimeField(AppStrings.endTime, _endTime, false)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            RecurrencePicker(
              recurrenceRule: _recurrenceRule,
              selectedDate: _selectedDate,
              onChanged: (rule) {
                setState(() => _recurrenceRule = rule);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: AppStrings.shiftValue,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.requiredField;
                }
                final parsed =
                    double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _informationsController,
              decoration: InputDecoration(
                labelText: AppStrings.shiftInformations,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.info_outline),
                alignLabelWithHint: true,
              ),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 15,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                AppStrings.completed,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              value: _isCompleted,
              onChanged: (value) => setState(() => _isCompleted = value),
              activeThumbColor: AppColors.success,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.save,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.red),
                ),
                child: Text(
                  AppStrings.delete,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalField() {
    final shiftNames = context.read<ShiftProvider>().getHospitalSuggestions();
    final recurrenceNames = context.read<RecurrenceProvider>().getHospitalSuggestions();
    final suggestions = {...shiftNames, ...recurrenceNames}.toList()..sort();

    return Autocomplete<String>(
      initialValue: _hospitalController.value,
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return suggestions;
        final query = textEditingValue.text.toLowerCase();
        return suggestions.where((s) => s.toLowerCase().contains(query));
      },
      onSelected: (selection) {
        _hospitalController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        _hospitalController = controller;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: AppStrings.hospital,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.local_hospital),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.requiredField;
            }
            return null;
          },
          onFieldSubmitted: (_) => onFieldSubmitted(),
        );
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
          lastDate: DateTime(DateTime.now().year, DateTime.now().month + 13, 0),
          locale: const Locale('pt', 'BR'),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.date,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(AppFormatters.formatDate(_selectedDate)),
      ),
    );
  }

  Widget _buildTimeField(String label, TimeOfDay time, bool isStart) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startTime = picked;
            } else {
              _endTime = picked;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.access_time),
        ),
        child: Text(_formatTimeOfDay(time)),
      ),
    );
  }

  Widget _buildEventTypeToggle() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'shift',
            label: Text(AppStrings.eventTypeShift, softWrap: false),
            icon: Icon(Icons.work_outline, size: 18),
          ),
          ButtonSegment(
            value: 'block',
            label: Text(AppStrings.eventTypeBlock, softWrap: false),
            icon: Icon(Icons.block, size: 18),
          ),
        ],
      selected: {_eventType},
      onSelectionChanged: (selection) {
        if (selection.contains('block')) {
          setState(() => _eventType = 'block');
        } else if (selection.contains('shift')) {
          setState(() => _eventType = 'shift');
        }
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      ),
    );
  }

  Widget _buildTipoIcon() {
    if (_selectedType == 'Diurno') {
      return Icon(Icons.wb_sunny, color: Colors.amber[700], size: 22);
    }
    if (_selectedType == 'Noturno') {
      return Icon(Icons.nightlight_round, color: Colors.blue[700], size: 22);
    }
    if (_selectedType == '24h') {
      return Icon(Icons.schedule, color: Colors.orange[700], size: 22);
    }
    return Text(
      _selectedType.isNotEmpty ? _selectedType.substring(0, 1) : '',
      style: TextStyle(
        color: AppColors.getHospitalColor(_hospitalController.text),
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final shiftProvider = context.read<ShiftProvider>();
    final recurrenceProvider = context.read<RecurrenceProvider>();
    final reportProvider = context.read<ReportProvider>();
    final hospitalName = _hospitalController.text.trim();
    final startStr = _formatTimeOfDay(_startTime);
    final endStr = _formatTimeOfDay(_endTime);
    final duration = AppFormatters.calculateDurationHours(startStr, endStr);
    final value =
        double.parse(_valueController.text.trim().replaceAll(',', '.'));
    final informationsRaw = _informationsController.text.trim();
    final String? informations = informationsRaw.isEmpty ? null : informationsRaw;

    try {
      if (isEditing) {
        if (widget.shift!.isFromRecurrence) {
          final choice = await _showRecurringEditDialog();
          if (choice == null) return;

          final recId = widget.shift!.sourceRecurrenceId!;
          if (choice == 'all') {
            final def = recurrenceProvider.getById(recId);
            if (def != null) {
              final newStartDate = _selectedDate;
              final startChanged = def.startDate != newStartDate;

              await recurrenceProvider.update(def.copyWith(
                hospitalName: hospitalName,
                startDate: newStartDate,
                startTime: startStr,
                endTime: endStr,
                durationHours: duration,
                value: value,
                type: _selectedType,
                isAllDay: _isAllDay,
                informations: informations,
                excludedDates: startChanged ? [] : null,
              ));
            }
          } else if (choice == 'thisAndFollowing') {
            await recurrenceProvider.interruptFromDate(recId, widget.shift!.date);
            await recurrenceProvider.add(
              hospitalName: hospitalName,
              startDate: widget.shift!.date,
              startTime: startStr,
              endTime: endStr,
              durationHours: duration,
              value: value,
              type: _selectedType,
              isAllDay: _isAllDay,
              informations: informations,
              rule: _recurrenceRule.isNone
                  ? recurrenceProvider.getById(recId)?.rule ?? RecurrenceRule()
                  : _recurrenceRule,
            );
          } else {
            await recurrenceProvider.addExclusion(recId, widget.shift!.date);
            await shiftProvider.addShift(
              hospitalName: hospitalName,
              date: _selectedDate,
              startTime: startStr,
              endTime: endStr,
              durationHours: duration,
              value: value,
              type: _selectedType,
              isAllDay: _isAllDay,
              isCompleted: _isCompleted,
              informations: informations,
            );
          }
        } else {
          if (!_recurrenceRule.isNone) {
            await shiftProvider.deleteShift(widget.shift!.id);
            await recurrenceProvider.add(
              hospitalName: hospitalName,
              startDate: _selectedDate,
              startTime: startStr,
              endTime: endStr,
              durationHours: duration,
              value: value,
              type: _selectedType,
              isAllDay: _isAllDay,
              informations: informations,
              rule: _recurrenceRule,
            );
          } else {
            final updated = widget.shift!.copyWith(
              hospitalName: hospitalName,
              date: _selectedDate,
              startTime: startStr,
              endTime: endStr,
              durationHours: duration,
              value: value,
              type: _selectedType,
              isAllDay: _isAllDay,
              isCompleted: _isCompleted,
              informations: informations,
            );
            await shiftProvider.updateShift(updated);
          }
        }
      } else {
        if (!_recurrenceRule.isNone) {
          await recurrenceProvider.add(
            hospitalName: hospitalName,
            startDate: _selectedDate,
            startTime: startStr,
            endTime: endStr,
            durationHours: duration,
            value: value,
            type: _selectedType,
            isAllDay: _isAllDay,
            informations: informations,
            rule: _recurrenceRule,
          );
        } else {
          await shiftProvider.addShift(
            hospitalName: hospitalName,
            date: _selectedDate,
            startTime: startStr,
            endTime: endStr,
            durationHours: duration,
            value: value,
            type: _selectedType,
            isAllDay: _isAllDay,
            isCompleted: _isCompleted,
            informations: informations,
          );
        }
      }

      if (mounted) {
        final archive = ArchiveService(
          shiftProvider: shiftProvider,
          recurrenceProvider: recurrenceProvider,
          reportProvider: reportProvider,
          userId: shiftProvider.shifts.isNotEmpty ? 'local' : 'local',
        );
        await archive.regenerateReportIfNeeded(
            _selectedDate.year, _selectedDate.month);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<String?> _showRecurringEditDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.editRecurringTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text(AppStrings.editOnlyThis),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'this'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text(AppStrings.editThisAndFollowing),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'thisAndFollowing'),
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text(AppStrings.editAllInSeries),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }

  void _delete() async {
    if (widget.shift!.isFromRecurrence) {
      final choice = await _showRecurringDeleteDialog();
      if (choice == null || !mounted) return;

      final recurrenceProvider = context.read<RecurrenceProvider>();
      final recId = widget.shift!.sourceRecurrenceId!;
      try {
        if (choice == 'all') {
          await recurrenceProvider.deleteAll(recId);
        } else if (choice == 'thisAndFollowing') {
          await recurrenceProvider.interruptFromDate(recId, widget.shift!.date);
        } else {
          await recurrenceProvider.addExclusion(recId, widget.shift!.date);
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteError)),
          );
        }
        return;
      }
      if (mounted) Navigator.of(context).pop();
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.delete),
          content: const Text(AppStrings.deleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.no),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(AppStrings.yes),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        try {
          await context.read<ShiftProvider>().deleteShift(widget.shift!.id);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.deleteError)),
            );
          }
          return;
        }
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<String?> _showRecurringDeleteDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteRecurringTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event, color: Colors.red),
              title: const Text(AppStrings.deleteOnlyThis),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'this'),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward, color: Colors.red),
              title: const Text(AppStrings.editThisAndFollowing),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'thisAndFollowing'),
            ),
            ListTile(
              leading: const Icon(Icons.repeat, color: Colors.red),
              title: const Text(AppStrings.editAllInSeries),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(context, 'all'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
        ],
      ),
    );
  }
}
