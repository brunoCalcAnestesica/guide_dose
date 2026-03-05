import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CircularProgressCard extends StatelessWidget {
  final double percentage;
  final String label;
  final String value;

  const CircularProgressCard({
    super.key,
    required this.percentage,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percentage > 0
                        ? AppColors.highlightBlue
                        : Colors.grey.shade300,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: percentage > 0
                        ? AppColors.textDark
                        : AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
