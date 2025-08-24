import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../constants/map_constants.dart';
import '../../services/track_service.dart';
import 'truck_marker.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final TrackService _trackService = TrackService();

  LatLng _currentTruckPosition = MapConstants.currentTruckPosition;
  List<LatLng> _completedRoute = [];
  List<LatLng> _remainingRoute = MapConstants.garbageCollectionRoute;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  void _initializeTracking() {
    // Listen to truck position updates
    _trackService.truckPositionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentTruckPosition = position;
        });
      }
    });

    // Listen to route progress updates
    _trackService.routeProgressStream.listen((completedRoute) {
      if (mounted) {
        setState(() {
          _completedRoute = completedRoute;
          _remainingRoute = _trackService.getRemainingRoute();
        });
      }
    });

    // Start tracking simulation
    _trackService.startTracking();
  }

  @override
  void dispose() {
    _trackService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // Neumorphic shadow effect
          BoxShadow(
            color: AppColors.shadowDark,
            offset: const Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            offset: const Offset(-8, -8),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: MapConstants.tagbilaranCenter,
            initialZoom: MapConstants.initialZoom,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: MapConstants.osmTileUrl,
              userAgentPackageName: 'com.example.green_tabiliran',
              maxNativeZoom: 19,
            ),

            // Completed route polyline (green)
            if (_completedRoute.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _completedRoute,
                    color: Color(MapConstants.completedRouteColorValue),
                    strokeWidth: 4.0,
                    pattern: const StrokePattern.solid(),
                  ),
                ],
              ),

            // Remaining route polyline (gray)
            if (_remainingRoute.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _remainingRoute,
                    color: Color(MapConstants.pendingRouteColorValue),
                    strokeWidth: 3.0,
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),

            // Full planned route polyline (main route)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: MapConstants.garbageCollectionRoute,
                  color: Color(
                    MapConstants.routeColorValue,
                  ).withValues(alpha: 0.6),
                  strokeWidth: 2.0,
                  pattern: StrokePattern.dashed(segments: const [5, 5]),
                ),
              ],
            ),

            // Route markers (collection points)
            MarkerLayer(
              markers: MapConstants.garbageCollectionRoute
                  .asMap()
                  .entries
                  .map(
                    (entry) => Marker(
                      width: 20.0,
                      height: 20.0,
                      point: entry.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _completedRoute.contains(entry.value)
                              ? Color(MapConstants.completedRouteColorValue)
                              : Color(MapConstants.pendingRouteColorValue),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.pureWhite,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: const TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            // Truck marker
            MarkerLayer(
              markers: [
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: _currentTruckPosition,
                  child: const TruckMarker(size: 50.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
