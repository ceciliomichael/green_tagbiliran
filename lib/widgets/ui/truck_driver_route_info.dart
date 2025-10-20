import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TruckDriverRouteInfo extends StatelessWidget {
  const TruckDriverRouteInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Route Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Location must be detected before starting route\n'
            '• Choose barangay and specific end location area\n'
            '• Users and admin will be notified when you start\n'
            '• Your location will be tracked during the route\n'
            '• Use the map to monitor your progress',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

