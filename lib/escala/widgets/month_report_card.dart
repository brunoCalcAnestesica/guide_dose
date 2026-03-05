import 'package:flutter/material.dart';
import '../models/shift_report.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class MonthReportCard extends StatelessWidget {
  final ShiftReport report;
  final VoidCallback onViewDetails;

  const MonthReportCard({
    super.key,
    required this.report,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Relatório arquivado',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (report.isComplete)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Completo',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${report.pendingCount} pendente${report.pendingCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  context,
                  icon: Icons.event_note,
                  label: 'Plantões',
                  value: '${report.shiftsCount}',
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  icon: Icons.schedule,
                  label: 'Horas',
                  value: AppFormatters.formatHours(report.totalHours),
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  icon: Icons.payments_outlined,
                  label: 'Valor total',
                  value: AppFormatters.formatCurrency(report.totalValue),
                ),
                if (report.paidValue > 0) ...[
                  const SizedBox(height: 4),
                  _buildStatRow(
                    context,
                    icon: Icons.check_circle_outline,
                    label: 'Pago',
                    value: AppFormatters.formatCurrency(report.paidValue),
                    valueColor: Colors.green,
                  ),
                ],
                if (report.pendingValue > 0) ...[
                  const SizedBox(height: 4),
                  _buildStatRow(
                    context,
                    icon: Icons.pending_outlined,
                    label: 'Pendente',
                    value: AppFormatters.formatCurrency(report.pendingValue),
                    valueColor: Colors.orange,
                  ),
                ],
                if (report.byHospital.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Por hospital',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: report.byHospital.entries.map((e) {
                      final color = AppColors.getHospitalColor(e.key);
                      return Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        avatar: CircleAvatar(
                          backgroundColor: color,
                          radius: 8,
                        ),
                        label: Text(
                          '${e.key}: ${e.value}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Ver detalhes'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
