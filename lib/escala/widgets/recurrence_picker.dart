import 'package:flutter/material.dart';
import '../models/recurrence_rule.dart';
import '../utils/constants.dart';
import 'custom_recurrence_dialog.dart';

class RecurrencePicker extends StatelessWidget {
  final RecurrenceRule recurrenceRule;
  final DateTime selectedDate;
  final ValueChanged<RecurrenceRule> onChanged;

  const RecurrencePicker({
    super.key,
    required this.recurrenceRule,
    required this.selectedDate,
    required this.onChanged,
  });

  String _getDisplayText() {
    switch (recurrenceRule.type) {
      case 'none':
        return AppStrings.recurrenceNone;
      case 'daily':
        return AppStrings.recurrenceDaily;
      case 'weekly':
        final dayName =
            AppStrings.weekDayLabelsFull[selectedDate.weekday - 1];
        return '${AppStrings.recurrenceWeekly} na $dayName';
      case 'monthly':
        return '${AppStrings.recurrenceMonthly} no dia ${selectedDate.day}';
      case 'monthlyWeekday':
        return AppStrings.monthlyWeekdayLabel(selectedDate);
      case 'yearly':
        return AppStrings.recurrenceYearly;
      case 'weekdays':
        return AppStrings.recurrenceWeekdays;
      case 'custom':
        return _getCustomDisplayText();
      default:
        return AppStrings.recurrenceNone;
    }
  }

  String _getCustomDisplayText() {
    final interval = recurrenceRule.interval;
    String unit;

    if (recurrenceRule.daysOfWeek.isNotEmpty) {
      unit = interval == 1 ? 'semana' : '$interval semanas';
      final days = recurrenceRule.daysOfWeek
          .map((d) => AppStrings.weekDayLabels[d - 1])
          .join(', ');
      return 'A cada $unit ($days)';
    }

    unit = interval == 1 ? 'dia' : '$interval dias';
    return 'A cada $unit';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showRecurrenceOptions(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppStrings.recurrence,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.repeat),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          _getDisplayText(),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  void _showRecurrenceOptions(BuildContext context) {
    final dayName = AppStrings.weekDayLabelsFull[selectedDate.weekday - 1];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    AppStrings.recurrence,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _buildOption(
                  context,
                  AppStrings.recurrenceNone,
                  'none',
                  recurrenceRule.type == 'none',
                ),
                _buildOption(
                  context,
                  AppStrings.recurrenceDaily,
                  'daily',
                  recurrenceRule.type == 'daily',
                ),
                _buildOption(
                  context,
                  '${AppStrings.recurrenceWeekly} na $dayName',
                  'weekly',
                  recurrenceRule.type == 'weekly',
                ),
                _buildOption(
                  context,
                  '${AppStrings.recurrenceMonthly} no dia ${selectedDate.day}',
                  'monthly',
                  recurrenceRule.type == 'monthly',
                ),
                _buildMonthlyWeekdayOption(context),
                _buildOption(
                  context,
                  AppStrings.recurrenceYearly,
                  'yearly',
                  recurrenceRule.type == 'yearly',
                ),
                _buildOption(
                  context,
                  AppStrings.recurrenceWeekdays,
                  'weekdays',
                  recurrenceRule.type == 'weekdays',
                ),
                const Divider(height: 1),
                _buildCustomOption(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    String label,
    String type,
    bool isSelected,
  ) {
    return ListTile(
      leading: isSelected
          ? const Icon(Icons.check, color: AppColors.highlightBlue)
          : const SizedBox(width: 24),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.highlightBlue : AppColors.textDark,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onChanged(RecurrenceRule(type: type));
      },
    );
  }

  Widget _buildMonthlyWeekdayOption(BuildContext context) {
    final isSelected = recurrenceRule.type == 'monthlyWeekday';
    final label = AppStrings.monthlyWeekdayLabel(selectedDate);
    final occurrence = AppStrings.weekdayOccurrenceInMonth(selectedDate);

    return ListTile(
      leading: isSelected
          ? const Icon(Icons.check, color: AppColors.highlightBlue)
          : const SizedBox(width: 24),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.highlightBlue : AppColors.textDark,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onChanged(RecurrenceRule(
          type: 'monthlyWeekday',
          weekOfMonth: occurrence,
          daysOfWeek: [selectedDate.weekday],
        ));
      },
    );
  }

  Widget _buildCustomOption(BuildContext context) {
    final isSelected = recurrenceRule.type == 'custom';
    return ListTile(
      leading: isSelected
          ? const Icon(Icons.check, color: AppColors.highlightBlue)
          : const SizedBox(width: 24),
      title: Text(
        AppStrings.recurrenceCustom,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.highlightBlue : AppColors.textDark,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        Navigator.pop(context);
        final result = await showDialog<RecurrenceRule>(
          context: context,
          builder: (_) => CustomRecurrenceDialog(
            initialRule: recurrenceRule.type == 'custom'
                ? recurrenceRule
                : RecurrenceRule(type: 'custom'),
            selectedDate: selectedDate,
          ),
        );
        if (result != null) {
          onChanged(result);
        }
      },
    );
  }
}
