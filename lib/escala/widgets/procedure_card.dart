import 'package:flutter/material.dart';
import '../models/procedure.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProcedureCard extends StatelessWidget {
  final Procedure procedure;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;
  final bool showDate;
  final bool isOnBlockedDay;

  const ProcedureCard({
    super.key,
    required this.procedure,
    required this.onTap,
    this.onToggleComplete,
    this.showDate = false,
    this.isOnBlockedDay = false,
  });

  @override
  Widget build(BuildContext context) {
    const hospitalColor = AppColors.highlightBlue;

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
                  color: hospitalColor,
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
                        const Icon(Icons.medical_services_outlined,
                            size: 14, color: hospitalColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            procedure.procedureType,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
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
                            AppFormatters.formatDateShort(procedure.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(Icons.local_hospital,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            procedure.hospitalName.isNotEmpty
                                ? procedure.hospitalName
                                : 'Sem hospital',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppFormatters.formatCurrency(procedure.value),
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
                          color: procedure.isCompleted
                              ? AppColors.success.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          procedure.isCompleted ? 'Pago' : 'Pendente',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: procedure.isCompleted
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
