import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProducaoDisplayType {
  static const String all = 'all';
  static const String shifts = 'shifts';
}

class ProducaoFilterState {
  final String displayType;
  final String? hospitalName;
  final DateTime? dateStart;
  final DateTime? dateEnd;

  const ProducaoFilterState({
    this.displayType = ProducaoDisplayType.all,
    this.hospitalName,
    this.dateStart,
    this.dateEnd,
  });

  bool get hasAnyFilter =>
      displayType != ProducaoDisplayType.all ||
      hospitalName != null ||
      dateStart != null ||
      dateEnd != null;

  ProducaoFilterState copyWith({
    String? displayType,
    String? hospitalName,
    DateTime? dateStart,
    DateTime? dateEnd,
  }) {
    return ProducaoFilterState(
      displayType: displayType ?? this.displayType,
      hospitalName: hospitalName ?? this.hospitalName,
      dateStart: dateStart ?? this.dateStart,
      dateEnd: dateEnd ?? this.dateEnd,
    );
  }
}

Future<ProducaoFilterState?> showProducaoFilterSheet(
  BuildContext context, {
  required ProducaoFilterState initial,
  required DateTime displayedMonth,
}) async {
  return showModalBottomSheet<ProducaoFilterState>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _ProducaoFilterSheet(
      initial: initial,
      displayedMonth: displayedMonth,
    ),
  );
}

class _ProducaoFilterSheet extends StatefulWidget {
  final ProducaoFilterState initial;
  final DateTime displayedMonth;

  const _ProducaoFilterSheet({
    required this.initial,
    required this.displayedMonth,
  });

  @override
  State<_ProducaoFilterSheet> createState() => _ProducaoFilterSheetState();
}

class _ProducaoFilterSheetState extends State<_ProducaoFilterSheet> {
  late String _displayType;
  late String? _hospitalName;
  late DateTime? _dateStart;
  late DateTime? _dateEnd;

  @override
  void initState() {
    super.initState();
    _displayType = widget.initial.displayType;
    _hospitalName = widget.initial.hospitalName;
    _dateStart = widget.initial.dateStart;
    _dateEnd = widget.initial.dateEnd;
  }

  void _clearFilters() {
    setState(() {
      _displayType = ProducaoDisplayType.all;
      _hospitalName = null;
      _dateStart = null;
      _dateEnd = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(ProducaoFilterState(
      displayType: _displayType,
      hospitalName: _hospitalName,
      dateStart: _dateStart,
      dateEnd: _dateEnd,
    ));
  }

  Future<void> _pickDateStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateStart ?? widget.displayedMonth,
      firstDate: DateTime(DateTime.now().year, DateTime.now().month - 3, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month + 13, 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateStart = picked;
        if (_dateEnd != null && _dateEnd!.isBefore(picked)) {
          _dateEnd = picked;
        }
      });
    }
  }

  Future<void> _pickDateEnd() async {
    final initial = _dateEnd ?? _dateStart ?? widget.displayedMonth;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _dateStart ?? DateTime(DateTime.now().year, DateTime.now().month - 3, 1),
      lastDate: DateTime(DateTime.now().year, DateTime.now().month + 13, 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateEnd = picked;
        if (_dateStart != null && _dateStart!.isAfter(picked)) {
          _dateStart = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shiftNames = context.watch<ShiftProvider>().getHospitalSuggestions();
    final recurrenceNames = context.watch<RecurrenceProvider>().getHospitalSuggestions();
    final hospitalSuggestions = {...shiftNames, ...recurrenceNames}.toList()..sort();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    AppStrings.filterTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(AppStrings.filterClear),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _sectionTitle(AppStrings.filterDisplayType),
                  _displayTypeTile(ProducaoDisplayType.all, AppStrings.filterAll, Icons.list),
                  _displayTypeTile(ProducaoDisplayType.shifts, AppStrings.filterShifts, Icons.work_outline),
                  const SizedBox(height: 16),
                  _sectionTitle(AppStrings.filterByHospital),
                  _hospitalTile(null, 'Todos'),
                  ...hospitalSuggestions.map((name) => _hospitalTile(name, name)),
                  const SizedBox(height: 16),
                  _sectionTitle(AppStrings.filterDateRange),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.filterDateStart),
                    trailing: Text(
                      _dateStart != null
                          ? AppFormatters.formatDate(_dateStart!)
                          : '—',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: _pickDateStart,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(AppStrings.filterDateEnd),
                    trailing: Text(
                      _dateEnd != null
                          ? AppFormatters.formatDate(_dateEnd!)
                          : '—',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    onTap: _pickDateEnd,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text(AppStrings.filterApply),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
    );
  }

  Widget _hospitalTile(String? name, String label) {
    final selected = _hospitalName == name;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, color: AppColors.highlightBlue) : null,
      onTap: () => setState(() => _hospitalName = name),
    );
  }

  Widget _displayTypeTile(String value, String label, IconData icon) {
    final selected = _displayType == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 20, color: selected ? AppColors.highlightBlue : null),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, color: AppColors.highlightBlue) : null,
      onTap: () => setState(() => _displayType = value),
    );
  }
}
