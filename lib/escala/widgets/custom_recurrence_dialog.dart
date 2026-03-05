import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/recurrence_rule.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class CustomRecurrenceDialog extends StatefulWidget {
  final RecurrenceRule initialRule;
  final DateTime selectedDate;

  const CustomRecurrenceDialog({
    super.key,
    required this.initialRule,
    required this.selectedDate,
  });

  @override
  State<CustomRecurrenceDialog> createState() => _CustomRecurrenceDialogState();
}

class _CustomRecurrenceDialogState extends State<CustomRecurrenceDialog> {
  late TextEditingController _intervalController;
  late String _selectedUnit; // days, weeks, months, years
  late List<int> _selectedDays; // 1=seg...7=dom
  late String _endType; // never, date, count
  late DateTime? _endDate;
  late TextEditingController _endCountController;

  @override
  void initState() {
    super.initState();
    _intervalController = TextEditingController(
      text: widget.initialRule.interval.toString(),
    );

    if (widget.initialRule.daysOfWeek.isNotEmpty) {
      _selectedUnit = 'weeks';
    } else {
      _selectedUnit = 'days';
    }

    _selectedDays = List<int>.from(widget.initialRule.daysOfWeek);
    if (_selectedDays.isEmpty) {
      _selectedDays = [widget.selectedDate.weekday];
    }

    _endType = widget.initialRule.endType;
    _endDate = widget.initialRule.endDate ??
        widget.selectedDate.add(const Duration(days: 90));
    _endCountController = TextEditingController(
      text: (widget.initialRule.endCount ?? 10).toString(),
    );
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _endCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      AppStrings.customRecurrenceTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildIntervalSection(),
              if (_selectedUnit == 'weeks') ...[
                const SizedBox(height: 20),
                _buildWeekdaySelector(),
              ],
              const SizedBox(height: 24),
              _buildEndSection(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    AppStrings.done,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.every,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 70,
              child: TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'days', child: Text(AppStrings.days)),
                  DropdownMenuItem(
                      value: 'weeks', child: Text(AppStrings.weeks)),
                  DropdownMenuItem(
                      value: 'months', child: Text(AppStrings.months)),
                  DropdownMenuItem(
                      value: 'years', child: Text(AppStrings.years)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedUnit = value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repetir nos dias',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final dayNum = index + 1; // 1=seg...7=dom
            final isSelected = _selectedDays.contains(dayNum);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected && _selectedDays.length > 1) {
                    _selectedDays.remove(dayNum);
                  } else if (!isSelected) {
                    _selectedDays.add(dayNum);
                    _selectedDays.sort();
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.highlightBlue
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  AppStrings.weekDayLabels[index].substring(0, 1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textDark,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEndSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.endsLabel,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        _buildEndOption(
          AppStrings.endsNever,
          'never',
          trailing: null,
        ),
        const SizedBox(height: 8),
        _buildEndOption(
          AppStrings.endsOnDate,
          'date',
          trailing: GestureDetector(
            onTap: () async {
              setState(() => _endType = 'date');
              final picked = await showDatePicker(
                context: context,
                initialDate: _endDate ?? DateTime.now(),
                firstDate: widget.selectedDate,
                lastDate: DateTime(DateTime.now().year, DateTime.now().month + 13, 0),
                locale: const Locale('pt', 'BR'),
              );
              if (picked != null) {
                setState(() => _endDate = picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _endDate != null
                    ? AppFormatters.formatDate(_endDate!)
                    : 'Selecionar',
                style: TextStyle(
                  color: _endType == 'date'
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildEndOption(
          AppStrings.endsAfterCount,
          'count',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: _endCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.center,
                  enabled: _endType == 'count',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  onTap: () => setState(() => _endType = 'count'),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.occurrences,
                style: TextStyle(
                  color: _endType == 'count'
                      ? AppColors.textDark
                      : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEndOption(String label, String value, {Widget? trailing}) {
    final isSelected = _endType == value;
    return GestureDetector(
      onTap: () => setState(() => _endType = value),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.highlightBlue : Colors.grey,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.highlightBlue,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );
  }

  void _save() {
    final interval =
        int.tryParse(_intervalController.text) ?? 1;
    final endCount =
        int.tryParse(_endCountController.text) ?? 10;

    final rule = RecurrenceRule(
      type: 'custom',
      interval: interval < 1 ? 1 : interval,
      daysOfWeek: _selectedUnit == 'weeks' ? _selectedDays : [],
      endType: _endType,
      endDate: _endType == 'date' ? _endDate : null,
      endCount: _endType == 'count' ? endCount : null,
    );

    Navigator.pop(context, rule);
  }
}
