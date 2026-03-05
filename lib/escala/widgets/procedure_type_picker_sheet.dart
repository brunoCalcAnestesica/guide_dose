import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/procedure_type.dart';
import '../providers/procedure_type_provider.dart';
import '../utils/constants.dart';

class ProcedureTypePickerSheet extends StatefulWidget {
  final String? selectedTypeName;
  final void Function(ProcedureType type) onSelected;

  const ProcedureTypePickerSheet({
    super.key,
    required this.selectedTypeName,
    required this.onSelected,
  });

  @override
  State<ProcedureTypePickerSheet> createState() =>
      _ProcedureTypePickerSheetState();
}

class _ProcedureTypePickerSheetState extends State<ProcedureTypePickerSheet> {
  bool _isAddingNew = false;
  ProcedureType? _editingType;

  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _startAdding() {
    setState(() {
      _isAddingNew = true;
      _editingType = null;
      _nameController.clear();
      _valueController.clear();
    });
  }

  void _startEditing(ProcedureType type) {
    setState(() {
      _isAddingNew = false;
      _editingType = type;
      _nameController.text = type.name;
      _valueController.text =
          type.defaultValue > 0 ? type.defaultValue.toStringAsFixed(2) : '';
    });
  }

  void _cancelForm() {
    setState(() {
      _isAddingNew = false;
      _editingType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final types = context.watch<ProcedureTypeProvider>().types;
    final showForm = _isAddingNew || _editingType != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Text(
                    showForm
                        ? (_editingType != null
                            ? AppStrings.editProcedureType
                            : AppStrings.addProcedureType)
                        : AppStrings.procedureTypeLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (!showForm)
                    IconButton(
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                            Icons.add, color: Colors.white, size: 18),
                      ),
                      onPressed: _startAdding,
                    ),
                  if (showForm)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _cancelForm,
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: showForm
                  ? _buildForm(context)
                  : _buildTypeList(types, scrollController),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeList(
      List<ProcedureType> types, ScrollController scrollController) {
    if (types.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Nenhum tipo cadastrado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _startAdding,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addProcedureType),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: types.length,
      itemBuilder: (context, index) {
        final type = types[index];
        final isSelected = type.name == widget.selectedTypeName;
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.highlightBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.highlightBlue,
              size: 22,
            ),
          ),
          title: Text(
            type.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.highlightBlue : AppColors.textDark,
            ),
          ),
          subtitle: Text(
            type.defaultValue > 0
                ? 'R\$ ${type.defaultValue.toStringAsFixed(2)}'
                : 'Sem valor padrão',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Icon(Icons.check, color: AppColors.highlightBlue),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    _startEditing(type);
                  } else if (value == 'delete') {
                    _confirmDelete(type);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Excluir',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          onTap: () => widget.onSelected(type),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppStrings.procedureTypeName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.medical_services_outlined),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.requiredField;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: AppStrings.defaultValueLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.attach_money),
              hintText: '0.00',
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saveType,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              AppStrings.save,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _saveType() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProcedureTypeProvider>();
    final name = _nameController.text.trim();
    final valueText = _valueController.text.trim().replaceAll(',', '.');
    final defaultValue =
        valueText.isNotEmpty ? (double.tryParse(valueText) ?? 0.0) : 0.0;

    try {
      if (_editingType != null) {
        final updated = _editingType!.copyWith(
          name: name,
          defaultValue: defaultValue,
        );
        await provider.updateType(updated);
        if (mounted) setState(() => _editingType = null);
      } else {
        await provider.addType(name: name, defaultValue: defaultValue);
        if (mounted) {
          final newType = provider.types.where((t) => t.name == name).first;
          widget.onSelected(newType);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
    }
  }

  void _confirmDelete(ProcedureType type) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: Text('Tem certeza que deseja excluir "${type.name}"?'),
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
        await context.read<ProcedureTypeProvider>().deleteType(type.id);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.deleteError)),
          );
        }
      }
    }
  }
}
