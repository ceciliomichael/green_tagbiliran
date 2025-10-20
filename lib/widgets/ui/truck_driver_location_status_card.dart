import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TruckDriverLocationStatusCard extends StatelessWidget {
  final bool isLocationDetected;
  final bool isDetectingLocation;
  final String? startLocation;
  final VoidCallback onRefresh;

  const TruckDriverLocationStatusCard({
    super.key,
    required this.isLocationDetected,
    required this.isDetectingLocation,
    this.startLocation,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
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
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isLocationDetected
                      ? AppColors.primaryGreen.withValues(alpha: 0.1)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isDetectingLocation
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        isLocationDetected
                            ? Icons.location_on
                            : Icons.location_off,
                        color: isLocationDetected
                            ? AppColors.primaryGreen
                            : AppColors.textSecondary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDetectingLocation
                          ? 'Detecting Location...'
                          : isLocationDetected
                          ? 'Location Detected'
                          : 'Location Not Available',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isDetectingLocation
                          ? 'Getting GPS coordinates'
                          : isLocationDetected
                          ? 'Ready to start route'
                          : 'GPS location required',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDetectingLocation && !isLocationDetected)
                GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
          if (isLocationDetected && startLocation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Current Location:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    startLocation!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
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
}

