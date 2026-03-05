import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../utils/constants.dart';

final DateFormat _dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

class PatientEditorScreen extends StatefulWidget {
  final Patient? patient;
  const PatientEditorScreen({super.key, this.patient});

  @override
  State<PatientEditorScreen> createState() => _PatientEditorScreenState();
}

class _PatientEditorScreenState extends State<PatientEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _initialsCtrl;
  late TextEditingController _ageCtrl;
  late String _ageUnit;
  DateTime? _admissionDate;
  late TextEditingController _bedCtrl;
  late TextEditingController _historyCtrl;
  late TextEditingController _devicesCtrl;
  late TextEditingController _diagnosisCtrl;
  late TextEditingController _atbCtrl;
  late TextEditingController _dvaCtrl;
  late TextEditingController _examsCtrl;
  late TextEditingController _pendingCtrl;
  late TextEditingController _observationsCtrl;

  bool get isEditing => widget.patient != null;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _initialsCtrl = TextEditingController(text: p?.initials ?? '');
    _ageCtrl = TextEditingController(
        text: p?.age != null ? p!.age.toString() : '');
    _ageUnit = p?.ageUnit ?? 'anos';
    _admissionDate = p?.admissionDate;
    _bedCtrl = TextEditingController(text: p?.bed ?? '');
    _historyCtrl = TextEditingController(text: p?.history ?? '');
    _devicesCtrl = TextEditingController(text: p?.devices ?? '');
    _diagnosisCtrl = TextEditingController(text: p?.diagnosis ?? '');
    _atbCtrl = TextEditingController(text: p?.antibiotics ?? '');
    _dvaCtrl = TextEditingController(text: p?.vasoactiveDrugs ?? '');
    _examsCtrl = TextEditingController(text: p?.exams ?? '');
    _pendingCtrl = TextEditingController(text: p?.pending ?? '');
    _observationsCtrl = TextEditingController(text: p?.observations ?? '');
  }

  @override
  void dispose() {
    _initialsCtrl.dispose();
    _ageCtrl.dispose();
    _bedCtrl.dispose();
    _historyCtrl.dispose();
    _devicesCtrl.dispose();
    _diagnosisCtrl.dispose();
    _atbCtrl.dispose();
    _dvaCtrl.dispose();
    _examsCtrl.dispose();
    _pendingCtrl.dispose();
    _observationsCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String label, {IconData? icon}) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: icon != null ? Icon(icon) : null,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Novo Paciente'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Arquivar',
              onPressed: _archive,
            ),
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: AppStrings.save,
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- Iniciais ---
            TextFormField(
              controller: _initialsCtrl,
              decoration: _deco('Iniciais do Nome', icon: Icons.person_outline),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe as iniciais' : null,
            ),
            const SizedBox(height: 16),

            // --- Idade + Unidade ---
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _ageCtrl,
                    decoration: _deco('Idade'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _ageUnit,
                    decoration: _deco('Unidade'),
                    items: const [
                      DropdownMenuItem(value: 'dias', child: Text('Dias')),
                      DropdownMenuItem(value: 'meses', child: Text('Meses')),
                      DropdownMenuItem(value: 'anos', child: Text('Anos')),
                    ],
                    onChanged: (v) => setState(() => _ageUnit = v ?? 'anos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- DIH ---
            InkWell(
              onTap: _pickAdmissionDate,
              child: InputDecorator(
                decoration: _deco('DIH - Data de Internação',
                    icon: Icons.calendar_today),
                child: Text(
                  _admissionDate != null
                      ? '${_dateFmt.format(_admissionDate!)}  (${_admissionDaysLabel()})'
                      : 'Selecionar data',
                  style: TextStyle(
                    color: _admissionDate != null
                        ? null
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- Leito ---
            TextFormField(
              controller: _bedCtrl,
              decoration: _deco('Leito', icon: Icons.bed_outlined),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // --- Antecedentes ---
            TextFormField(
              controller: _historyCtrl,
              decoration: _deco('Antecedentes', icon: Icons.history),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // --- Dispositivos ---
            TextFormField(
              controller: _devicesCtrl,
              decoration: _deco('Dispositivos', icon: Icons.medical_services_outlined),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // --- Impressão Diagnóstica ---
            TextFormField(
              controller: _diagnosisCtrl,
              decoration:
                  _deco('Impressão Diagnóstica', icon: Icons.assignment_outlined),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // --- ATB ---
            TextFormField(
              controller: _atbCtrl,
              decoration: _deco('ATB - Antibióticos',
                  icon: Icons.medication_outlined),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // --- DVA ---
            TextFormField(
              controller: _dvaCtrl,
              decoration: _deco('DVA - Drogas Vasoativas',
                  icon: Icons.bloodtype_outlined),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // --- Exames ---
            TextFormField(
              controller: _examsCtrl,
              decoration: _deco('Exames', icon: Icons.science_outlined),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // --- Pendência ---
            TextFormField(
              controller: _pendingCtrl,
              decoration: _deco('Pendências', icon: Icons.pending_actions),
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // --- Observações ---
            TextFormField(
              controller: _observationsCtrl,
              decoration: _deco('Observações', icon: Icons.notes),
              maxLines: null,
              minLines: 2,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // --- Salvar ---
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppStrings.save,
                  style: const TextStyle(fontSize: 16)),
            ),

            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _delete,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Colors.red),
                ),
                child: Text(AppStrings.delete,
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Pickers & actions ---

  String _admissionDaysLabel() {
    if (_admissionDate == null) return '';
    final d = DateTime.now().difference(_admissionDate!).inDays + 1;
    return '${d}º dia';
  }

  Future<void> _pickAdmissionDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _admissionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) setState(() => _admissionDate = picked);
  }

  // --- Save / Delete / Archive ---

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PatientProvider>();
    final now = DateTime.now();

    final patient = Patient(
      id: widget.patient?.id ?? 'patient_${now.millisecondsSinceEpoch}',
      initials: _initialsCtrl.text.trim(),
      age: double.tryParse(_ageCtrl.text.trim()),
      ageUnit: _ageUnit,
      admissionDate: _admissionDate,
      bed: _bedCtrl.text.trim(),
      history: _historyCtrl.text.trim(),
      devices: _devicesCtrl.text.trim(),
      diagnosis: _diagnosisCtrl.text.trim(),
      antibiotics: _atbCtrl.text.trim(),
      vasoactiveDrugs: _dvaCtrl.text.trim(),
      exams: _examsCtrl.text.trim(),
      pending: _pendingCtrl.text.trim(),
      observations: _observationsCtrl.text.trim(),
      createdAt: widget.patient?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (isEditing) {
        await provider.update(patient);
      } else {
        await provider.add(patient);
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

  void _archive() async {
    try {
      await context.read<PatientProvider>().archive(widget.patient!.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.saveError)),
        );
      }
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paciente arquivado')),
      );
      Navigator.of(context).pop();
    }
  }

  void _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.yes),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context
            .read<PatientProvider>()
            .delete(widget.patient!.id);
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
