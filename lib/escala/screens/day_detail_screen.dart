import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../models/blocked_day.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';
import '../providers/blocked_day_provider.dart';
import '../services/merged_shift_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/shift_card.dart';
import 'shift_form_screen.dart';

class DayDetailScreen extends StatelessWidget {
  final DateTime date;

  const DayDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formatHeader(date),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openShiftForm(context),
          ),
        ],
      ),
      body: Consumer3<ShiftProvider, RecurrenceProvider, BlockedDayProvider>(
        builder: (context, shiftProvider, recurrenceProvider, blockedDayProvider, _) {
          final merged = MergedShiftService(
            shiftProvider: shiftProvider,
            recurrenceProvider: recurrenceProvider,
          );
          final shifts = merged.getByDate(date);

          final blocked = blockedDayProvider.getForDate(date);
          final dayTotal = shifts.fold(0.0, (sum, s) => sum + s.value);

          return Column(
            children: [
              _buildDaySummary(context, shifts.length, dayTotal, colorScheme),
              const Divider(height: 1),
              Expanded(
                child: shifts.isEmpty && blocked == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_available,
                                size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.noShiftsForDay,
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          if (blocked != null)
                            Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(Icons.block, color: colorScheme.primary),
                                title: Text(blocked.label),
                              ),
                            ),
                          ...shifts.map((shift) => _buildDismissibleShiftCard(
                                context,
                                shift: shift,
                                shiftProvider: shiftProvider,
                                blocked: blocked,
                                onTap: () => _openShiftForm(context, shift: shift),
                              )),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySummary(
      BuildContext context, int count, double total, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$count plantão${count != 1 ? 'es' : ''}',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            'Total: ',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          Text(
            AppFormatters.formatCurrency(total),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _openShiftForm(BuildContext context, {shift}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShiftFormScreen(
          shift: shift,
          initialDate: date,
        ),
      ),
    );
  }

  Widget _buildDismissibleShiftCard(
    BuildContext context, {
    required Shift shift,
    required ShiftProvider shiftProvider,
    required BlockedDay? blocked,
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
        isOnBlockedDay: blocked != null,
        showInformations: true,
        onTap: onTap,
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

  String _formatHeader(DateTime d) {
    final dayOfWeek = AppFormatters.formatDayOfWeek(d);
    final capitalized = dayOfWeek[0].toUpperCase() + dayOfWeek.substring(1);
    return '$capitalized, ${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
}
