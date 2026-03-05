import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/blocked_day.dart';
import '../models/shift.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/report_provider.dart';
import '../providers/shift_provider.dart';
import '../screens/report_detail_screen.dart';
import '../screens/shift_form_screen.dart';
import '../services/holidays_service.dart';
import '../services/merged_shift_service.dart';
import '../../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'calendar_widget.dart';
import 'month_report_card.dart';
import 'shift_card.dart';
import '../screens/day_detail_screen.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  Map<DateTime, String>? _holidays;
  int? _holidaysYear;
  int? _lastHolidaysYearLoaded;
  int? _holidaysYearRequested;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final year = _displayedMonth.year;
    if (_lastHolidaysYearLoaded == year) return;
    if (_holidaysYearRequested == year) return;
    String countryCode = 'BR';
    try {
      countryCode = (Localizations.localeOf(context).countryCode ?? 'BR').trim().toUpperCase();
    } catch (_) {}
    if (countryCode.isEmpty) countryCode = 'BR';
    _holidaysYearRequested = year;
    HolidaysService().getHolidaysForYear(year, countryCode).then((map) {
      if (!mounted) return;
      setState(() {
        _holidays = map;
        _holidaysYear = year;
        _lastHolidaysYearLoaded = year;
        _holidaysYearRequested = null;
      });
    });
  }

  DateTime _minMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 3);
  }

  DateTime _maxMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 12);
  }

  bool _canGoPrevious() {
    final prev = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    return !prev.isBefore(_minMonth());
  }

  bool _canGoNext() {
    final next = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    return !next.isAfter(_maxMonth());
  }

  void _goToPreviousMonth() {
    if (!_canGoPrevious()) return;
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
      );
    });
    context.read<ShiftProvider>().ensureMonthLoaded(
      _displayedMonth.year,
      _displayedMonth.month,
    );
  }

  void _goToNextMonth() {
    if (!_canGoNext()) return;
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
      );
    });
    context.read<ShiftProvider>().ensureMonthLoaded(
      _displayedMonth.year,
      _displayedMonth.month,
    );
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  bool _isArchivedMonth(int year, int month) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month - 3);
    final displayed = DateTime(year, month);
    return displayed.isBefore(cutoff);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderAndCalendar(context),
        Expanded(child: _buildSummaryAndList(context)),
      ],
    );
  }

  /// Parte que só depende do mês exibido: não reconstrói ao trocar de dia.
  Widget _buildHeaderAndCalendar(BuildContext context) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    return Selector<ShiftProvider, (int, int, int)>(
      selector: (_, sp) => (year, month, sp.getByMonth(year, month).length),
      builder: (_, __, ___) {
        return Selector<RecurrenceProvider, (int, int)>(
          selector: (_, rp) => (year, rp.version),
          builder: (_, __, ___) {
        return Selector<BlockedDayProvider, (int, int)>(
          selector: (_, bp) => (year, bp.getForMonth(year, month).length),
          builder: (_, __, ___) {
                final shiftProvider = context.read<ShiftProvider>();
                final recurrenceProvider = context.read<RecurrenceProvider>();
                final blockedDayProvider = context.read<BlockedDayProvider>();

                final merged = MergedShiftService(
                  shiftProvider: shiftProvider,
                  recurrenceProvider: recurrenceProvider,
                );
                final monthShifts = merged.getByMonth(year, month);

                final daysWithShifts = monthShifts
                    .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
                    .toSet();
                final allDaysWithEvents = daysWithShifts;

                final Map<DateTime, List<Color>> dayColors = {};
                for (final shift in monthShifts) {
                  final day = DateTime(shift.date.year, shift.date.month, shift.date.day);
                  dayColors.putIfAbsent(day, () => []);
                  final color = AppColors.getHospitalColor(shift.hospitalName);
                  if (!dayColors[day]!.contains(color)) {
                    dayColors[day]!.add(color);
                  }
                }

                final useHolidays = _holidays != null && _holidaysYear == year;
                final holidayDates = useHolidays ? _holidays!.keys.toSet() : <DateTime>{};
                final holidayNames = useHolidays ? Map<DateTime, String>.from(_holidays!) : <DateTime, String>{};
                final blockedForMonth = blockedDayProvider.getForMonth(year, month);
                final blockedDayNumbers = blockedForMonth.keys.map((d) => d.day).toSet();
                final holidayDayNumbers = holidayDates
                    .where((d) => d.year == year && d.month == month)
                    .map((d) => d.day)
                    .toSet();
                final holidayNamesByDay = <int, String>{
                  for (final e in holidayNames.entries)
                    if (e.key.year == year && e.key.month == month)
                      e.key.day: e.value,
                  for (final e in blockedForMonth.entries) e.key.day: e.value,
                };

                final colorScheme = Theme.of(context).colorScheme;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, 2),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 24),
                            onPressed: _canGoPrevious() ? _goToPreviousMonth : null,
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _goToToday,
                            child: Text(
                              AppFormatters.formatMonthYear(_displayedMonth),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _buildAddButton(context),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 24),
                            onPressed: _canGoNext() ? _goToNextMonth : null,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                      child: CalendarWidget(
                        displayedMonth: _displayedMonth,
                        selectedDate: _selectedDate,
                        daysWithShifts: allDaysWithEvents,
                        dayColors: dayColors,
                        holidayDayNumbers: holidayDayNumbers,
                        blockedDayNumbers: blockedDayNumbers,
                        holidayNamesByDay: holidayNamesByDay,
                        onDaySelected: (date) {
                          if (date == _selectedDate) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DayDetailScreen(date: date),
                              ),
                            );
                          } else {
                            setState(() => _selectedDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  /// Parte que depende do dia selecionado: reconstrói só ao trocar de dia ou dados do dia.
  Widget _buildSummaryAndList(BuildContext context) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final selectedDate = _selectedDate;

    final isArchived = _isArchivedMonth(year, month);
    if (isArchived) {
      return Consumer<ReportProvider>(
        builder: (context, reportProv, _) {
          final report = reportProv.getByMonth(year, month);
          if (report != null) {
            return SingleChildScrollView(
              child: MonthReportCard(
                report: report,
                onViewDetails: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportDetailScreen(report: report),
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: Text(
              'Nenhum relatório para este mês',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        },
      );
    }

    return Selector<ShiftProvider, (DateTime, int, double)>(
      selector: (_, sp) => (
        selectedDate,
        sp.getByDate(selectedDate).length,
        sp.getTotalValueForMonth(year, month),
      ),
      builder: (_, shiftDayData, __) {
        return Selector<RecurrenceProvider, int>(
          selector: (_, rp) => rp.version,
          builder: (_, __, ___) {
        return Selector<BlockedDayProvider, (DateTime, BlockedDay?)>(
          selector: (_, bp) => (selectedDate, bp.getForDate(selectedDate)),
          builder: (_, blockedData, __) {
                final shiftProvider = context.read<ShiftProvider>();
                final recurrenceProvider = context.read<RecurrenceProvider>();
                final blockedDayProvider = context.read<BlockedDayProvider>();

                final merged = MergedShiftService(
                  shiftProvider: shiftProvider,
                  recurrenceProvider: recurrenceProvider,
                );
                final shiftsForDay = merged.getByDate(selectedDate);
                final selectedDayBlocked = blockedData.$2;

                final dayTotal = shiftsForDay.fold(0.0, (sum, s) => sum + s.value);
                final monthTotalValue = merged.getTotalValueForMonth(year, month);
                final hasEvents = shiftsForDay.isNotEmpty || selectedDayBlocked != null;
                final selectedDayHolidayName = _getHolidayNameForDate(selectedDate, blockedDayProvider);

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSummaryBar(dayTotal, monthTotalValue, selectedDayHolidayName),
                    const Divider(height: 1),
                    Expanded(
                      child: !hasEvents
                          ? Center(
                              child: Text(
                                AppStrings.noShiftsForDay,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
                              children: [
                                if (selectedDayBlocked != null)
                                  Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: Icon(Icons.block, color: Theme.of(context).colorScheme.primary),
                                      title: Text(selectedDayBlocked.label),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () async {
                                          try {
                                            await blockedDayProvider.remove(selectedDayBlocked.id);
                                          } catch (_) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text(AppStrings.deleteError)),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ...shiftsForDay.map((shift) => _buildDismissibleShiftCard(
                                      context,
                                      shift: shift,
                                      shiftProvider: shiftProvider,
                                      selectedDayBlocked: selectedDayBlocked != null,
                                      onTap: () => _openShiftForm(context, shift: shift),
                                    )),
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String? _getHolidayNameForDate(DateTime date, [BlockedDayProvider? blockedDayProvider]) {
    final blocked = blockedDayProvider?.getForDate(date);
    if (blocked != null) return blocked.label;
    if (_holidays == null) return null;
    for (final e in _holidays!.entries) {
      if (e.key.year == date.year &&
          e.key.month == date.month &&
          e.key.day == date.day) {
        return e.value;
      }
    }
    return null;
  }

  Widget _buildSummaryBar(
    double dayTotal,
    double monthTotal, [
    String? holidayName,
  ]) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.today, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Dia: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrency(dayTotal),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: colorScheme.outline,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.calendar_month, size: 14, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Mês: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrencyShort(monthTotal),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (holidayName != null && holidayName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.celebration_outlined, size: 14, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    holidayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openShiftForm(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.onPrimary, size: 20),
      ),
    );
  }

  void _openShiftForm(BuildContext context, {shift}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShiftFormScreen(
          shift: shift,
          initialDate: _selectedDate,
        ),
      ),
    );
  }

  Widget _buildDismissibleShiftCard(
    BuildContext context, {
    required Shift shift,
    required ShiftProvider shiftProvider,
    required bool selectedDayBlocked,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(shift.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Excluir',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
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
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                child: const Text(AppStrings.yes),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      onDismissed: (_) async {
        try {
          await shiftProvider.deleteShift(shift.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plantão excluído')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.deleteError)),
            );
          }
        }
      },
      child: ShiftCard(
        shift: shift,
        isOnBlockedDay: selectedDayBlocked,
        onTap: onTap,
        onToggleComplete: () async {
          try {
            if (shift.isFromRecurrence) {
              final recurrenceProvider = context.read<RecurrenceProvider>();
              await recurrenceProvider.togglePaid(
                  shift.sourceRecurrenceId!, shift.date);
            } else {
              await shiftProvider.toggleCompleted(shift.id);
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.saveError)),
              );
            }
          }
        },
      ),
    );
  }
}
