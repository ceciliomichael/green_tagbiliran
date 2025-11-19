import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../services/track_service.dart';
import '../../services/driver_location_service.dart';
import '../../services/auth_service.dart';

class TrackInfoCard extends StatefulWidget {
  final TrackService trackService;

  const TrackInfoCard({super.key, required this.trackService});

  @override
  State<TrackInfoCard> createState() => _TrackInfoCardState();
}

class _TrackInfoCardState extends State<TrackInfoCard> {
  final AuthService _authService = AuthService();
  LatLng? _userLocation;
  DriverLocation? _nearestDriver;
  Duration _estimatedArrival = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  void _initializeTracking() {
    // Listen to user location updates
    widget.trackService.userLocationStream.listen((location) {
      if (mounted) {
        setState(() {
          _userLocation = location;
        });
        _updateNearestDriver();
      }
    });

    // Listen to driver location updates
    widget.trackService.driverLocationsStream.listen((drivers) {
      if (mounted) {
        _updateNearestDriver();
      }
    });
  }

  void _updateNearestDriver() {
    if (_userLocation == null) return;

    final user = _authService.currentUser;
    if (user == null) return;

    final activeDrivers =
        widget.trackService.getActiveDriversForBarangay(user.barangay);

    if (activeDrivers.isEmpty) {
      setState(() {
        _nearestDriver = null;
        _estimatedArrival = Duration.zero;
      });
      return;
    }

    // Find nearest driver
    DriverLocation? nearest;
    double minDistance = double.infinity;

    for (final driver in activeDrivers) {
      final distance =
          widget.trackService.getDistance(driver.position, _userLocation!);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = driver;
      }
    }

    if (nearest != null) {
      final eta = widget.trackService.getEstimatedArrivalTime(
        nearest.position,
        _userLocation!,
      );

      setState(() {
        _nearestDriver = nearest;
        _estimatedArrival = eta;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m away';
    } else if (minutes > 0) {
      return '$minutes min away';
    } else {
      return 'Arriving now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveDriver = _nearestDriver != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: hasActiveDriver
                      ? AppColors.primaryGreen
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                  boxShadow: hasActiveDriver
                      ? [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasActiveDriver
                      ? 'Garbage Truck Active'
                      : 'No Active Trucks Nearby',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (hasActiveDriver) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Arrival',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(_estimatedArrival),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: AppColors.borderLight,
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Driver',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _nearestDriver!.driverName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Waiting for garbage trucks to start their route in your barangay...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}
