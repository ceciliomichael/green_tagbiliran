import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/driver_status.dart';
import '../../l10n/app_localizations.dart';

/// Linear progress indicator showing granular street-level progression
class StatusProgressIndicator extends StatelessWidget {
  final DriverStatus currentStatus;

  const StatusProgressIndicator({
    super.key,
    required this.currentStatus,
  });

  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'Northern Cogon':
        return const Color(0xFF42A5F5); // Blue
      case 'Central Cogon':
        return const Color(0xFF66BB6A); // Green
      case 'South Cogon':
        return const Color(0xFFFFA726); // Orange
      case 'West Cogon':
        return const Color(0xFFAB47BC); // Purple
      case 'Final Sweep':
        return const Color(0xFFEF5350); // Red
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = currentStatus.progressPercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.statusProgress,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$progress%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Current location display
          if (currentStatus != DriverStatus.notStarted)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getZoneColor(currentStatus.zone).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getZoneColor(currentStatus.zone).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: _getZoneColor(currentStatus.zone),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentStatus.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getZoneColor(currentStatus.zone),
                          ),
                        ),
                        if (currentStatus.zone != 'Starting Point' &&
                            currentStatus.zone != 'Completed')
                          Text(
                            currentStatus.zone,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getZoneColor(currentStatus.zone).withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentStatus.progressPercentage / 100;

    return Column(
      children: [
        // Progress bar
        SizedBox(
          height: 12,
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Progress bar
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getZoneColor(currentStatus.zone),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Zone indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildZoneIndicator('Northern', const Color(0xFF42A5F5), 1, 4),
            _buildZoneIndicator('Central', const Color(0xFF66BB6A), 5, 8),
            _buildZoneIndicator('South', const Color(0xFFFFA726), 9, 12),
            _buildZoneIndicator('West', const Color(0xFFAB47BC), 13, 15),
            _buildZoneIndicator('Final', const Color(0xFFEF5350), 16, 18),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneIndicator(String label, Color color, int startOrder, int endOrder) {
    final isActive = currentStatus.order >= startOrder;
    final isCurrent = currentStatus.order >= startOrder && currentStatus.order <= endOrder;

    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
