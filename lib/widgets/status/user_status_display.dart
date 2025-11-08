import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/driver_status.dart';
import '../../l10n/app_localizations.dart';

/// Compact card displaying current truck status for users
class UserStatusDisplay extends StatelessWidget {
  final DriverStatusRecord? statusRecord;
  final bool isLoading;

  const UserStatusDisplay({
    super.key,
    this.statusRecord,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return _buildLoadingState();
    }

    if (statusRecord == null) {
      return _buildEmptyState(l10n);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator row
          Row(
            children: [
              _buildStatusIndicator(statusRecord!.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trackingStatusTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStatusText(l10n, statusRecord!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (statusRecord!.isStale)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warningYellow,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        size: 14,
                        color: AppColors.warningYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.trackingStale,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.warningYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Last updated info
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${l10n.statusLastUpdated}: ${statusRecord!.getTimeSinceUpdate()}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (statusRecord!.statusMessage != null &&
              statusRecord!.statusMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusRecord!.statusMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
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

  Widget _buildStatusIndicator(DriverStatus status) {
    Color color;
    IconData icon;

    if (status == DriverStatus.notStarted) {
      color = AppColors.textSecondary;
      icon = Icons.schedule;
    } else if (status.isCompleted) {
      color = AppColors.successGreen;
      icon = Icons.check_circle;
    } else {
      // Active collection - use zone color
      color = _getZoneColor(status.zone);
      icon = Icons.local_shipping;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

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
        return AppColors.primaryGreen;
    }
  }

  String _getStatusText(AppLocalizations l10n, DriverStatusRecord record) {
    final status = record.status;
    if (status == DriverStatus.notStarted) {
      return l10n.statusNotStarted;
    } else if (status.isCompleted) {
      return l10n.statusCompletedInArea(record.barangay);
    } else {
      // Show current street name
      return 'Currently at ${status.displayName}';
    }
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.trackingNoStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

