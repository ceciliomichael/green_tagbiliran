import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/schedule.dart';

class ScheduleDeleteDialog extends StatelessWidget {
  final Schedule schedule;

  const ScheduleDeleteDialog({
    super.key,
    required this.schedule,
  });

  static Future<bool?> show(BuildContext context, Schedule schedule) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ScheduleDeleteDialog(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Delete Schedule',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete the schedule for ${schedule.barangay}? This action cannot be undone.',
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

