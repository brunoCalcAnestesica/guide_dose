import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/procedure.dart';
import '../providers/procedure_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/procedure_type_picker_sheet.dart';
import 'block_form_screen.dart';
import 'shift_form_screen.dart';

class ProcedureFormScreen extends StatefulWidget {
  final Procedure? procedure;
  final DateTime? initialDate;
  final String? initialHospitalName;

  const ProcedureFormScreen({
    super.key,
    this.procedure,
    this.initialDate,
    this.initialHospitalName,
  });

  @override
  State<ProcedureFormScreen> createState() => _ProcedureFormScreenState();
}

class _ProcedureFormScreenState extends State<ProcedureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _hospitalController;
  late DateTime _selectedDate;
  late String? _selectedProcedureType;
  String? _selectedProcedureTypeId;
  late TextEditingController _valueController;
  late bool _isCompleted;
  String? _procedureTypeError;

  bool get isEditing => widget.procedure != null;

  @override
  void initState() {
    super.initState();
    _hospitalController = TextEditingController(
      text: widget.procedure?.hospitalName ?? widget.initialHospitalName ?? '',
    );
    _selectedDate =
        widget.procedure?.date ?? widget.initialDate ?? DateTime.now();
    _selectedProcedureType = widget.procedure?.procedureType;
    _selectedProcedureTypeId = widget.procedure?.procedureTypeId;
    _valueController = TextEditingController(
      text: widget.procedure?.value.toStringAsFixed(2) ?? '',
    );
    _isCompleted = widget.procedure?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEditing ? AppStrings.editProcedure : AppStrings.addProcedure),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(context).padding.bottom + 80,
          ),
          children: [
            if (!isEditing) _buildEventTypeToggle(),
            if (!isEditing) const SizedBox(height: 16),
            _buildHospitalField(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildProcedureTypeField(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: AppStrings.procedureValue,
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
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed == null || parsed < 0) {
                  return 'Valor inválido';
                }
                return null;
              },
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
              child: const Text(
                AppStrings.save,
                style: TextStyle(fontSize: 16),
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
                child: const Text(
                  AppStrings.delete,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeToggle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'shift',
            label: Text(AppStrings.eventTypeShift, softWrap: false),
            icon: Icon(Icons.work_outline, size: 18),
          ),
          ButtonSegment(
            value: 'procedure',
            label: Text(AppStrings.eventTypeProcedure, softWrap: false),
            icon: Icon(Icons.medical_services_outlined, size: 18),
          ),
          ButtonSegment(
            value: 'block',
            label: Text(AppStrings.eventTypeBlock, softWrap: false),
            icon: Icon(Icons.block, size: 18),
          ),
        ],
      selected: const {'procedure'},
      onSelectionChanged: (selection) {
        if (selection.contains('shift')) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ShiftFormScreen(
                initialDate: _selectedDate,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              maintainState: true,
            ),
          );
        } else if (selection.contains('block')) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => BlockFormScreen(
                initialDate: _selectedDate,
              ),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              maintainState: true,
            ),
          );
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
          firstDate: DateTime(DateTime.now().year, DateTime.now().month - 3, 1),
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

  Widget _buildProcedureTypeField() {
    return InkWell(
      onTap: _showProcedureTypePicker,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.procedureTypeLabel,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.medical_services_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          errorText: _procedureTypeError,
        ),
        child: _selectedProcedureType != null
            ? Text(
                _selectedProcedureType!,
                style: const TextStyle(fontSize: 16),
              )
            : Text(
                AppStrings.selectProcedureType,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
              ),
      ),
    );
  }

  void _showProcedureTypePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return ProcedureTypePickerSheet(
          selectedTypeName: _selectedProcedureType,
          onSelected: (type) {
            setState(() {
              _selectedProcedureType = type.name;
              _selectedProcedureTypeId = type.id;
              _procedureTypeError = null;
              if (type.defaultValue > 0) {
                _valueController.text = type.defaultValue.toStringAsFixed(2);
              }
            });
            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void _save() async {
    if (_selectedProcedureType == null) {
      setState(() => _procedureTypeError = AppStrings.selectProcedureType);
      return;
    }
    setState(() => _procedureTypeError = null);

    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProcedureProvider>();
    final hospitalName = _hospitalController.text.trim();
    final value =
        double.parse(_valueController.text.trim().replaceAll(',', '.'));

    try {
      if (isEditing) {
        final updated = widget.procedure!.copyWith(
          hospitalName: hospitalName,
          date: _selectedDate,
          procedureType: _selectedProcedureType!,
          procedureTypeId: _selectedProcedureTypeId,
          value: value,
          isCompleted: _isCompleted,
        );
        await provider.updateProcedure(updated);
      } else {
        await provider.addProcedure(
          hospitalName: hospitalName,
          date: _selectedDate,
          procedureType: _selectedProcedureType!,
          procedureTypeId: _selectedProcedureTypeId,
          value: value,
          isCompleted: _isCompleted,
        );
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

  void _delete() async {
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
        await context.read<ProcedureProvider>().deleteProcedure(widget.procedure!.id);
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
