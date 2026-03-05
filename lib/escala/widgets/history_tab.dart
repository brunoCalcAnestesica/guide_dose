import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../screens/shift_form_screen.dart';
import '../services/merged_shift_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import 'empty_state.dart';
import 'producao_filter_sheet.dart';
import 'shift_card.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late DateTime _displayedMonth;
  ProducaoFilterState? _advancedFilter;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  Future<void> _openFilterSheet() async {
    final result = await showProducaoFilterSheet(
      context,
      initial: _advancedFilter ?? const ProducaoFilterState(),
      displayedMonth: _displayedMonth,
    );
    if (result != null && mounted) {
      setState(() => _advancedFilter = result);
    }
  }

  String get _effectiveDisplayType =>
      _advancedFilter?.displayType ?? ProducaoDisplayType.all;

  void _goToPreviousMonth() {
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

  @override
  Widget build(BuildContext context) {
    final shiftProvider = context.watch<ShiftProvider>();
    final recurrenceProvider = context.watch<RecurrenceProvider>();
    final merged = MergedShiftService(
      shiftProvider: shiftProvider,
      recurrenceProvider: recurrenceProvider,
    );
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;

    final dateStart = _advancedFilter?.dateStart ??
        DateTime(year, month, 1);
    final dateEnd = _advancedFilter?.dateEnd ??
        DateTime(year, month + 1, 0);
    final useDateRange = _advancedFilter?.dateStart != null ||
        _advancedFilter?.dateEnd != null;

    List<Shift> monthShifts = useDateRange
        ? merged.getByDateRange(dateStart, dateEnd)
        : merged.getByMonth(year, month);

    if (_advancedFilter?.hospitalName != null) {
      final hName = _advancedFilter!.hospitalName!;
      monthShifts = monthShifts.where((s) => s.hospitalName == hName).toList();
    }

    final displayType = _effectiveDisplayType;
    final showShifts = displayType == ProducaoDisplayType.all || displayType == ProducaoDisplayType.shifts;
    final filteredShifts = showShifts ? monthShifts : <Shift>[];

    final totalCompletedValue = filteredShifts
        .where((s) => s.isCompleted)
        .fold<double>(0.0, (sum, s) => sum + s.value);
    final totalPendingValue = filteredShifts
        .where((s) => !s.isCompleted)
        .fold<double>(0.0, (sum, s) => sum + s.value);
    final hasEvents = filteredShifts.isNotEmpty;
    final shiftSectionLength = filteredShifts.isEmpty ? 0 : 2 + filteredShifts.length;
    final eventItemCount = hasEvents ? shiftSectionLength + 1 : 0;
    final totalCount = 2 + (hasEvents ? eventItemCount : 1);

    return ListView.builder(
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildMonthNavigation();
        }
        if (index == 1) {
          return _buildSummaryRowWithFilter(
            filteredShifts.length,
            totalCompletedValue,
            totalPendingValue,
          );
        }
        if (index == 2) {
          if (!hasEvents) {
            return const Padding(
              padding: EdgeInsets.only(top: 16),
              child: SizedBox(
                height: 300,
                child: EmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: AppStrings.noShiftsForMonth,
                  subtitle: AppStrings.noShiftsForMonthSubtitle,
                ),
              ),
            );
          }
          return const SizedBox(height: 16);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildEventListItem(
            context,
            index - 3,
            shiftProvider,
            context.read<BlockedDayProvider>(),
            filteredShifts,
          ),
        );
      },
    );
  }

  Widget _buildEventListItem(
    BuildContext context,
    int index,
    ShiftProvider shiftProvider,
    BlockedDayProvider blockedDayProvider,
    List<Shift> monthShifts,
  ) {
    if (monthShifts.isNotEmpty) {
      if (index == 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: _buildSectionHeader(
            context,
            'Plantões',
            Icons.work_outline,
            _countsPerHospital(monthShifts),
            totalValue: monthShifts.fold<double>(0.0, (sum, s) => sum + s.value),
          ),
        );
      }
      if (index >= 1 && index <= monthShifts.length) {
        final shift = monthShifts[index - 1];
        final shiftDate = DateTime(shift.date.year, shift.date.month, shift.date.day);
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
            showDate: true,
            isOnBlockedDay: blockedDayProvider.getForDate(shiftDate) != null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShiftFormScreen(shift: shift),
                ),
              );
            },
            onToggleComplete: () async {
              try {
                if (shift.isFromRecurrence) {
                  final rp = context.read<RecurrenceProvider>();
                  await rp.togglePaid(
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
      if (index == monthShifts.length + 1) {
        return const SizedBox(height: 12);
      }
    }
    return const SizedBox(height: 16);
  }

  Widget _buildMonthNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 24),
            onPressed: _goToPreviousMonth,
          ),
          const Spacer(),
          Text(
            AppFormatters.formatMonthYearShort(_displayedMonth),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 24),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRowWithFilter(
    int shiftCount,
    double completedValue,
    double pendingValue,
  ) {
    final theme = Theme.of(context);
    final hasFilter = _advancedFilter?.hasAnyFilter ?? false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _buildSummarySection(
            shiftCount,
            completedValue,
            pendingValue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              size: 22,
              color: hasFilter ? theme.colorScheme.primary : null,
            ),
            tooltip: hasFilter ? AppStrings.filterActiveTooltip : AppStrings.filterButton,
            onPressed: _openFilterSheet,
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(36, 36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    int shiftCount,
    double completedValue,
    double pendingValue,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryRow(
                  'Plantões:',
                  '$shiftCount',
                  valueColor: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryRow(
                  AppStrings.completedShifts,
                  AppFormatters.formatCurrency(completedValue),
                  valueColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSummaryRow(
                  AppStrings.pendingValueLabel,
                  AppFormatters.formatCurrency(pendingValue),
                  valueColor: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {required Color valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  List<(int count, Color color)> _countsPerHospital(List<Shift> shifts) {
    if (shifts.isEmpty) return [(0, AppColors.highlightBlue)];
    final order = <String>[];
    for (final s in shifts) {
      if (!order.contains(s.hospitalName)) order.add(s.hospitalName);
    }
    final count = <String, int>{};
    for (final s in shifts) {
      count[s.hospitalName] = (count[s.hospitalName] ?? 0) + 1;
    }
    return [
      for (final name in order)
        (count[name]!, AppColors.getHospitalColor(name))
    ];
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    List<(int count, Color color)> countColorPairs, {
    double? totalValue,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textLight),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          if (countColorPairs.isEmpty)
            _buildCountBubble(0, AppColors.highlightBlue)
          else
            ...countColorPairs.map((e) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildCountBubble(e.$1, e.$2),
                )),
          if (totalValue != null) ...[
            const Spacer(),
            Text(
              AppFormatters.formatCurrency(totalValue),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountBubble(int count, Color color) {
    final isLight = color.computeLuminance() > 0.5;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isLight ? AppColors.textDark : Colors.white,
        ),
      ),
    );
  }
}
