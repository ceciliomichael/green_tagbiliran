import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.3),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications Sent',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Send important announcements and updates to your community. Notifications help keep users informed about events, schedule changes, and important information.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Click "Send Notification" to get started',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

