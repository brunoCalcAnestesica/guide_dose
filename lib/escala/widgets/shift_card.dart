import 'package:flutter/material.dart';
import '../models/shift.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ShiftCard extends StatelessWidget {
  final Shift shift;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;
  final bool showDate;
  final bool isOnBlockedDay;
  final bool showInformations;

  const ShiftCard({
    super.key,
    required this.shift,
    required this.onTap,
    this.onToggleComplete,
    this.showDate = false,
    this.isOnBlockedDay = false,
    this.showInformations = false,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = AppColors.getHospitalColor(shift.hospitalName);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shift.hospitalName.isNotEmpty
                                ? shift.hospitalName
                                : 'Sem hospital',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.getHospitalColor(shift.hospitalName)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            shift.type,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.getHospitalColor(shift.hospitalName),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (shift.isFromRecurrence) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.repeat,
                              size: 13, color: Colors.grey.shade500),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showDate) ...[
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 3),
                          Text(
                            AppFormatters.formatDateShort(shift.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                            shift.isAllDay ? Icons.calendar_today : Icons.access_time,
                            size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Text(
                          shift.isAllDay
                              ? 'Dia inteiro'
                              : '${shift.startTime} - ${shift.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (isOnBlockedDay) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.shiftRepassReminder,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (showInformations &&
                        shift.informations != null &&
                        shift.informations!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shift.informations!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(shift.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (onToggleComplete != null)
                    GestureDetector(
                      onTap: onToggleComplete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: shift.isCompleted
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          shift.isCompleted ? 'Pago' : 'Pendente',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: shift.isCompleted
                                ? AppColors.success
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
