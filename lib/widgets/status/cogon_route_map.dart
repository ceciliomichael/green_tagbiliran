import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../constants/colors.dart';
import '../../constants/cogon_route_data.dart';
import '../../models/driver_status.dart';

/// Visual map showing Cogon collection route with granular street-level tracking
class CogonRouteMap extends StatelessWidget {
  final DriverStatus? currentStatus;

  const CogonRouteMap({
    super.key,
    this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    final status = currentStatus ?? DriverStatus.notStarted;
    final currentWaypointIndex = status.order;
    final currentPosition = CogonRouteData.waypoints[currentWaypointIndex].position;
    
    // Get completed waypoints up to current position
    final completedWaypoints = CogonRouteData.waypoints
        .sublist(0, currentWaypointIndex + 1)
        .map((w) => w.position)
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: currentPosition,
          initialZoom: 14.5,
          minZoom: 13.0,
          maxZoom: 17.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
        ),
        children: [
          // Map tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.green_tabiliran',
          ),
          
          // Full route polyline (gray - not yet completed)
          PolylineLayer(
            polylines: [
              Polyline(
                points: CogonRouteData.routePolyline,
                strokeWidth: 4.0,
                color: AppColors.borderDark.withValues(alpha: 0.4),
                borderStrokeWidth: 1.0,
                borderColor: Colors.white,
              ),
            ],
          ),
          
          // Completed route polyline (colored by zone)
          if (completedWaypoints.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: completedWaypoints,
                  strokeWidth: 6.0,
                  color: _getZoneColor(status.zone),
                  borderStrokeWidth: 2.0,
                  borderColor: Colors.white,
                ),
              ],
            ),
          
          // Waypoint markers
          MarkerLayer(
            markers: [
              // Start marker (City Hall)
              Marker(
                point: CogonRouteData.waypoints.first.position,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5), // Blue
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // End marker (Bus Terminal)
              Marker(
                point: CogonRouteData.waypoints.last.position,
                width: 40,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: status.isCompleted
                        ? AppColors.successGreen 
                        : AppColors.textSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              
              // Current truck position marker
              if (!status.isCompleted)
                Marker(
                  point: currentPosition,
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing circle animation effect
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: _getZoneColor(status.zone).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Truck marker
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _getZoneColor(status.zone),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getZoneColor(status.zone).withValues(alpha: 0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Attribution
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () {},
              ),
            ],
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
        return AppColors.primaryGreen;
    }
  }
}
