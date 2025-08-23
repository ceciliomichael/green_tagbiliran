import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/home_data.dart';

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleItem scheduleItem;

  const ScheduleItemWidget({super.key, required this.scheduleItem});

  Color _getScheduleColor(String day) {
    if (day.contains('Monday') || day.contains('Friday')) {
      return const Color(
        0xFF2196F3,
      ).withValues(alpha: 0.1); // Blue for weekdays
    } else if (day.contains('Tuesday') || day.contains('Saturday')) {
      return const Color(
        0xFF4CAF50,
      ).withValues(alpha: 0.1); // Green for Tue/Sat
    } else {
      return const Color(0xFFFF9800).withValues(alpha: 0.1); // Orange for mixed
    }
  }

  IconData _getScheduleIcon(String time) {
    if (time.contains('AM')) {
      return Icons.wb_sunny_outlined; // Morning icon
    } else {
      return Icons.nightlight_outlined; // Evening icon
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon and color indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getScheduleColor(scheduleItem.day),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getScheduleIcon(scheduleItem.time),
                color: scheduleItem.time.contains('AM')
                    ? const Color(0xFFFF9800)
                    : const Color(0xFF3F51B5),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Schedule details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheduleItem.barangay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          scheduleItem.day,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scheduleItem.time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
