import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../services/track_service.dart';

class TrackInfoCard extends StatefulWidget {
  final TrackService trackService;
  
  const TrackInfoCard({
    super.key,
    required this.trackService,
  });

  @override
  State<TrackInfoCard> createState() => _TrackInfoCardState();
}

class _TrackInfoCardState extends State<TrackInfoCard> {
  Duration _estimatedArrival = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateEstimatedArrival();
    
    // Update estimated arrival time when truck position changes
    widget.trackService.truckPositionStream.listen((_) {
      _updateEstimatedArrival();
    });
  }

  void _updateEstimatedArrival() {
    // Simulate user location (could be from GPS)
    const userLocation = LatLng(9.648, 123.856);
    final eta = widget.trackService.getEstimatedArrivalTime(userLocation);
    
    if (mounted) {
      setState(() {
        _estimatedArrival = eta;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Truck is active',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Arrival',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_estimatedArrival),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Current Location',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<LatLng>(
                    stream: widget.trackService.truckPositionStream,
                    initialData: widget.trackService.currentPosition,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? widget.trackService.currentPosition;
                      return Text(
                        '${position.latitude.toStringAsFixed(3)}, ${position.longitude.toStringAsFixed(3)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
