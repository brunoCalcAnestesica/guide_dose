import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final Set<DateTime> daysWithShifts;
  final Map<DateTime, List<Color>> dayColors;
  /// O(1) lookup: day-of-month (1-31) for the displayed month.
  final Set<int> holidayDayNumbers;
  /// O(1) lookup: day-of-month (1-31) for the displayed month.
  final Set<int> blockedDayNumbers;
  /// O(1) lookup: day-of-month -> holiday/blocked label.
  final Map<int, String> holidayNamesByDay;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarWidget({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.daysWithShifts,
    this.dayColors = const {},
    this.holidayDayNumbers = const {},
    this.blockedDayNumbers = const {},
    this.holidayNamesByDay = const {},
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = <Widget>[];

    const weekDays = ['dom.', 'seg.', 'ter.', 'qua.', 'qui.', 'sex.', 'sáb.'];
    for (final day in weekDays) {
      days.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    for (int i = 0; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }

    final colorScheme = Theme.of(context).colorScheme;

    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(displayedMonth.year, displayedMonth.month, day);
      final isToday = date == today;
      final isSelected = selectedDate != null &&
          date.year == selectedDate!.year &&
          date.month == selectedDate!.month &&
          date.day == selectedDate!.day;
      final isBlocked = blockedDayNumbers.contains(day);
      final isHoliday = holidayDayNumbers.contains(day);
      final hasShift = daysWithShifts.contains(date);
      final colors = dayColors[date] ?? [];
      final holidayName = holidayNamesByDay[day];

      Color? cellColor;
      if (isSelected) {
        cellColor = colorScheme.primary;
      } else if (isBlocked) {
        cellColor = AppColors.blockedDay;
      } else if (isHoliday) {
        cellColor = AppColors.holiday;
      } else if (isToday) {
        cellColor = colorScheme.primary.withValues(alpha: 0.1);
      }

      TextStyle dayTextStyle = TextStyle(
        fontSize: 15,
        fontWeight:
            isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
        color: isSelected
            ? colorScheme.onPrimary
            : isToday
                ? colorScheme.primary
                : colorScheme.onSurface,
      );
      if ((isHoliday || isBlocked) && !isSelected) {
        dayTextStyle = dayTextStyle.copyWith(
          color: colorScheme.onSurface,
        );
      }

      Widget cell = GestureDetector(
        onTap: () => onDaySelected(date),
        child: Container(
          decoration: BoxDecoration(
            color: cellColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: dayTextStyle,
              ),
              if (hasShift)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: colors.isNotEmpty
                        ? colors
                            .take(3)
                            .map((c) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : c,
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList()
                        : [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                  ),
                ),
            ],
          ),
        ),
      );

      if (holidayName != null && holidayName.isNotEmpty) {
        cell = Tooltip(
          message: holidayName,
          child: cell,
        );
      }
      days.add(cell);
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      padding: EdgeInsets.zero,
      children: days,
    );
  }
}
