import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/map_constants.dart';

class RouteLegend extends StatelessWidget {
  const RouteLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Route Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(MapConstants.completedRouteColorValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Completed Route',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 20,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(MapConstants.pendingRouteColorValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Remaining Route',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
