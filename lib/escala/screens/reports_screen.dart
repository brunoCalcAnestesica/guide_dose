import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift_report.dart';
import '../providers/report_provider.dart';
import '../utils/formatters.dart';
import 'report_detail_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _monthNames = [
    '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ReportProvider>(
      builder: (context, reportProv, _) {
        final years = reportProv.getYears();
        if (years.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 56,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum relatório disponível',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plantões pagos com mais de 6 meses são\narquivados automaticamente aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: years.length,
          itemBuilder: (context, index) =>
              _buildYearSection(context, reportProv, years[index]),
        );
      },
    );
  }

  Widget _buildYearSection(
    BuildContext context,
    ReportProvider reportProv,
    int year,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reports = reportProv.getByYear(year);
    final totalValue = reportProv.getTotalValueForYear(year);
    final totalHours = reportProv.getTotalHoursForYear(year);
    final paidValue = reportProv.getPaidValueForYear(year);
    final pendingValue = reportProv.getPendingValueForYear(year);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: reports.isNotEmpty && reports == reportProv.getByYear(reportProv.getYears().first),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Row(
            children: [
              Text(
                '$year',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.formatCurrencyShort(totalValue),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                '${reports.length} meses • ${AppFormatters.formatHours(totalHours)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (pendingValue > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${AppFormatters.formatCurrencyShort(pendingValue)} pendente',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(height: 1, indent: 20, endIndent: 20),
            _buildYearSummary(context, totalHours, paidValue, pendingValue),
            ...reports.map((r) => _buildMonthTile(context, r)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSummary(
    BuildContext context,
    double totalHours,
    double paidValue,
    double pendingValue,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _buildMiniStat(
              context,
              icon: Icons.schedule,
              label: 'Horas',
              value: AppFormatters.formatHours(totalHours),
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              context,
              icon: Icons.check_circle_outline,
              label: 'Pago',
              value: AppFormatters.formatCurrencyShort(paidValue),
              valueColor: Colors.green[700],
            ),
          ),
          Expanded(
            child: _buildMiniStat(
              context,
              icon: Icons.pending_outlined,
              label: 'Pendente',
              value: AppFormatters.formatCurrencyShort(pendingValue),
              valueColor: pendingValue > 0 ? Colors.orange : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthTile(BuildContext context, ShiftReport report) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          '${report.month}'.padLeft(2, '0'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ),
      title: Text(
        _monthNames[report.month],
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        '${report.shiftsCount} plantões • ${AppFormatters.formatHours(report.totalHours)}',
        style: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppFormatters.formatCurrencyShort(report.totalValue),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            report.isComplete
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 18,
            color: report.isComplete ? Colors.green : Colors.orange,
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(report: report),
          ),
        );
      },
    );
  }
}
