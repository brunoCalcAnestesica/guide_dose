import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shift.dart';
import '../models/shift_report.dart';
import '../providers/report_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ReportDetailScreen extends StatefulWidget {
  final ShiftReport report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String get _title {
    const months = [
      '', 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return '${months[widget.report.month]} ${widget.report.year}';
  }

  List<Shift> _getPendingShiftsForMonth(ShiftProvider sp) {
    final year = widget.report.year;
    final month = widget.report.month;
    return sp.getByMonth(year, month).where((s) {
      return !s.isCompleted;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _confirmDeleteShift(BuildContext context, Shift shift) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir plantão pendente'),
        content: Text(
          'Tem certeza que deseja excluir o plantão de '
          '${AppFormatters.formatDate(shift.date)}?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await context.read<ShiftProvider>().deleteShift(shift.id);
        if (context.mounted) {
          final reportProv = context.read<ReportProvider>();
          reportProv.loadReports();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plantão pendente excluído')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível excluir. Tente novamente.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final report = widget.report;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(_title),
      ),
      body: Consumer<ShiftProvider>(
        builder: (context, shiftProv, _) {
          final pendingShifts = _getPendingShiftsForMonth(shiftProv);

          return Column(
            children: [
              _buildArchiveBanner(context),
              _buildSummaryHeader(context, pendingShifts.length),
              const Divider(height: 1),
              Expanded(
                child: (report.details.isEmpty && pendingShifts.isEmpty)
                    ? Center(
                        child: Text(
                          'Nenhum plantão neste mês',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          if (pendingShifts.isNotEmpty) ...[
                            _buildSectionHeader(
                              context,
                              icon: Icons.pending_outlined,
                              label: 'Plantões pendentes (não pagos)',
                              color: Colors.orange,
                            ),
                            ...pendingShifts.map(
                              (s) => _buildPendingShiftTile(context, s),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (report.details.isNotEmpty) ...[
                            _buildSectionHeader(
                              context,
                              icon: Icons.check_circle_outline,
                              label: 'Plantões arquivados (pagos)',
                              color: Colors.green,
                            ),
                            ...report.details.map(
                              (d) => _buildDetailTile(context, d),
                            ),
                          ],
                        ],
                      ),
              ),
              _buildFooter(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchiveBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Dados arquivados (somente leitura)',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, int livePendingCount) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = widget.report;
    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Plantões',
                  value: '${report.shiftsCount}',
                  icon: Icons.event_note,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Horas',
                  value: AppFormatters.formatHours(report.totalHours),
                  icon: Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  label: 'Valor',
                  value: AppFormatters.formatCurrencyShort(report.totalValue),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          if (livePendingCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_outlined, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$livePendingCount plantão(ões) pendente(s) — deslize para excluir',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingShiftTile(BuildContext context, Shift shift) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = AppColors.getHospitalColor(shift.hospitalName);
    final hospitalName = shift.hospitalName;

    return Dismissible(
      key: ValueKey('pending_${shift.id}'),
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
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text(
              'Excluir',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        _confirmDeleteShift(context, shift);
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospitalName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${AppFormatters.formatDateShort(shift.date)} • ${shift.startTime} - ${shift.endTime} • ${shift.type}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(shift.value),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radio_button_unchecked, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Pendente',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: colorScheme.error.withValues(alpha: 0.7),
                ),
                onPressed: () => _confirmDeleteShift(context, shift),
                tooltip: 'Excluir plantão pendente',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, ShiftReportDetail detail) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = AppColors.getHospitalColor(detail.hospital);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.hospital.isNotEmpty ? detail.hospital : '—',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDateStr(detail.date)} • ${detail.start} - ${detail.end} • ${detail.type}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.formatCurrency(detail.value),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      detail.paid ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 14,
                      color: detail.paid ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detail.paid ? 'Pago' : 'Pendente',
                      style: TextStyle(
                        fontSize: 11,
                        color: detail.paid ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final report = widget.report;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total pago',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(report.paidValue),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total geral',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(report.totalValue),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateStr(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return AppFormatters.formatDateShort(date);
  }
}
