import 'dart:async';
import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/shift.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../services/merged_shift_service.dart';
import '../../theme/app_colors.dart' as theme;
import '../utils/constants.dart';

const String _androidWidgetCalendar = 'CalendarWidgetProvider';
const String _androidWidgetAgenda = 'AgendaWidgetProvider';
const String _appGroupId = 'group.com.companyname.medcalc.group';

const List<String> _monthNames = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

const List<String> _weekDayNames = [
  'domingo', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado',
];

const int _agendaDays = 3;

class WidgetService {
  static Timer? _updateTimer;
  static const Duration _updateDebounce = Duration(milliseconds: 600);

  static ShiftProvider? _shiftProvider;
  static RecurrenceProvider? _recurrenceProvider;
  static BlockedDayProvider? _blockedDayProvider;

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static void setProviders({
    required ShiftProvider shiftProvider,
    required RecurrenceProvider recurrenceProvider,
    required BlockedDayProvider blockedDayProvider,
  }) {
    _shiftProvider = shiftProvider;
    _recurrenceProvider = recurrenceProvider;
    _blockedDayProvider = blockedDayProvider;
  }

  static void scheduleUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer(_updateDebounce, () {
      _updateTimer = null;
      updateWidgetData();
    });
  }

  static Future<void> updateWidgetData() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final MergedShiftService? merged =
          _shiftProvider != null && _recurrenceProvider != null
              ? MergedShiftService(
                  shiftProvider: _shiftProvider!,
                  recurrenceProvider: _recurrenceProvider!,
                )
              : null;

      await _buildCalendarData(now, today, merged);
      await _buildAgendaData(today, merged);

      await HomeWidget.updateWidget(
        androidName: _androidWidgetCalendar,
        iOSName: 'CalendarWidget',
      );
      await HomeWidget.updateWidget(
        androidName: _androidWidgetAgenda,
        iOSName: 'AgendaWidget',
      );
    } catch (_) {}
  }

  static Future<void> _buildCalendarData(
    DateTime now,
    DateTime today,
    MergedShiftService? merged,
  ) async {
    final year = now.year;
    final month = now.month;

    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday % 7;

    final blockedForMonth = _blockedDayProvider?.getForMonth(year, month);

    final cells = <Map<String, dynamic>>[];

    for (int i = 0; i < startWeekday; i++) {
      cells.add({
        'day': 0,
        'inMonth': false,
        'isToday': false,
        'events': <Map<String, dynamic>>[],
      });
    }

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final isToday = d == today.day && month == today.month && year == today.year;

      final events = <Map<String, dynamic>>[];

      if (merged != null) {
        final shifts = merged.getByDate(date);
        for (final s in shifts) {
          events.add({
            'n': _abbreviate(s.hospitalName),
            'c': AppColors.getHospitalColor(s.hospitalName).toARGB32(),
          });
        }
      }

      if (blockedForMonth != null) {
        final blockedEntry = blockedForMonth.entries
            .where((e) => e.key.day == d)
            .firstOrNull;
        if (blockedEntry != null) {
          events.add({
            'n': blockedEntry.value,
            'c': theme.AppColors.blockedDay.toARGB32(),
          });
        }
      }

      cells.add({
        'day': d,
        'inMonth': true,
        'isToday': isToday,
        'events': events,
      });
    }

    final label = '${_monthNames[month - 1]} $year';
    await HomeWidget.saveWidgetData('calendar_month_label', label);
    await HomeWidget.saveWidgetData('calendar_year', year);
    await HomeWidget.saveWidgetData('calendar_month', month);
    await HomeWidget.saveWidgetData('calendar_days_json', jsonEncode(cells));
  }

  static Future<void> _buildAgendaData(
    DateTime today,
    MergedShiftService? merged,
  ) async {
    final items = <Map<String, String>>[];

    for (int offset = 0; offset < _agendaDays; offset++) {
      final date = today.add(Duration(days: offset));
      final shifts = merged?.getByDate(date) ?? <Shift>[];

      final blocked = _blockedDayProvider?.getForDate(date);
      final hasContent = shifts.isNotEmpty || blocked != null;
      if (!hasContent && offset > 0) continue;

      items.add({'t': 'h', 'label': _dayHeaderLabel(date, today)});

      if (blocked != null) {
        items.add({
          't': 'e',
          'hospital': blocked.label,
          'time': 'Dia inteiro',
          'type': 'Bloqueado',
          'color': theme.AppColors.blockedDay.toARGB32().toString(),
          'date': _isoDate(date),
        });
      }

      for (final s in shifts) {
        items.add({
          't': 'e',
          'hospital': s.hospitalName,
          'time': '${s.startTime} - ${s.endTime}',
          'type': s.type,
          'color': AppColors.getHospitalColor(s.hospitalName).toARGB32().toString(),
          'date': _isoDate(date),
        });
      }
    }

    if (items.isEmpty) {
      items.add({'t': 'h', 'label': _dayHeaderLabel(today, today)});
    }

    await HomeWidget.saveWidgetData('agenda_items_json', jsonEncode(items));
  }

  static String _abbreviate(String name) {
    if (name.length <= 10) return name;
    final words = name.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      final first = words.first;
      return first.length <= 10 ? first : '${first.substring(0, 9)}.';
    }
    return '${name.substring(0, 9)}.';
  }

  static String _isoDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _dayHeaderLabel(DateTime date, DateTime today) {
    final diff = date.difference(today).inDays;
    final dayName = _weekDayNames[date.weekday % 7];
    final dayMonth = '${date.day} de ${_monthNames[date.month - 1].toLowerCase().substring(0, 3)}';
    if (diff == 0) return 'Hoje, $dayMonth';
    if (diff == 1) return 'Amanhã, $dayMonth';
    return '${dayName[0].toUpperCase()}${dayName.substring(1)}, $dayMonth';
  }
}
