import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/driver_status.dart';
import '../../services/status_tracking_service.dart';

/// Simple one-button card for drivers to progress through collection route
class DriverStatusUpdateCard extends StatefulWidget {
  final String driverId;
  final String assignedBarangay;
  final DriverStatusRecord? currentStatus;
  final VoidCallback? onStatusUpdated;

  const DriverStatusUpdateCard({
    super.key,
    required this.driverId,
    required this.assignedBarangay,
    this.currentStatus,
    this.onStatusUpdated,
  });

  @override
  State<DriverStatusUpdateCard> createState() => _DriverStatusUpdateCardState();
}

class _DriverStatusUpdateCardState extends State<DriverStatusUpdateCard> {
  final StatusTrackingService _statusService = StatusTrackingService();
  bool _isUpdating = false;

  Future<void> _moveToNextLocation() async {
    final currentStatus = widget.currentStatus?.status ?? DriverStatus.notStarted;
    final nextStatus = currentStatus.next;
    
    if (nextStatus == null) {
      // Already completed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Collection already completed!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    final message = 'Now at ${nextStatus.displayName}';
    final result = await _statusService.updateStatus(
      driverId: widget.driverId,
      barangay: widget.assignedBarangay,
      status: nextStatus,
      message: message,
    );

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Moved to ${nextStatus.displayName}')),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        widget.onStatusUpdated?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(result.error ?? 'Failed to update')),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _resetCollection() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Collection?'),
        content: const Text('This will reset the collection route to the beginning. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    final result = await _statusService.updateStatus(
      driverId: widget.driverId,
      barangay: widget.assignedBarangay,
      status: DriverStatus.notStarted,
      message: 'Collection reset',
    );

    if (mounted) {
      setState(() {
        _isUpdating = false;
      });

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Collection reset successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        widget.onStatusUpdated?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.currentStatus?.status ?? DriverStatus.notStarted;
    final nextStatus = currentStatus.next;
    final isCompleted = currentStatus.isCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: const Offset(6, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(-6, -6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current location display
          _buildCurrentLocationDisplay(currentStatus),
          
          const SizedBox(height: 24),
          
          // Next location button
          if (!isCompleted)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _moveToNextLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getZoneColor(nextStatus?.zone ?? 'Starting Point'),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isUpdating
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_forward, size: 24),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              nextStatus == null
                                  ? 'Start Collection'
                                  : 'Next: ${nextStatus.displayName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          
          // Completed state
          if (isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.successGreen,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.successGreen, size: 32),
                  const SizedBox(width: 12),
                  const Text(
                    'Collection Complete!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Reset button
          if (currentStatus != DriverStatus.notStarted)
            TextButton.icon(
              onPressed: _isUpdating ? null : _resetCollection,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset Collection'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationDisplay(DriverStatus status) {
    if (status == DriverStatus.notStarted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.borderLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Start',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tap "Next" to begin collection route',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Color zoneColor = _getZoneColor(status.zone);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: zoneColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: zoneColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: zoneColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: zoneColor,
                      ),
                    ),
                    Text(
                      status.zone,
                      style: TextStyle(
                        fontSize: 14,
                        color: zoneColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: zoneColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${status.progressPercentage}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: status.progressPercentage / 100,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation<Color>(zoneColor),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
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
      case 'Completed':
        return AppColors.successGreen;
      default:
        return AppColors.textSecondary;
    }
  }
}


