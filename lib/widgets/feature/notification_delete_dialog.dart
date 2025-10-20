import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/notification.dart';
import '../../services/notifications_service.dart';

class NotificationDeleteDialog extends StatelessWidget {
  final NotificationSummary notification;
  final String adminId;
  final VoidCallback onSuccess;

  const NotificationDeleteDialog({
    super.key,
    required this.notification,
    required this.adminId,
    required this.onSuccess,
  });

  Future<void> _handleDelete(BuildContext context) async {
    Navigator.pop(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      ),
    );

    try {
      final notificationsService = NotificationsService();
      final result = await notificationsService.deleteNotification(
        notificationId: notification.id,
        adminId: adminId,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  result.message ?? 'Notification deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          onSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  result.error ?? 'Failed to delete notification'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text(
        'Delete Notification',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${notification.title}"? This action cannot be undone.',
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => _handleDelete(context),
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

