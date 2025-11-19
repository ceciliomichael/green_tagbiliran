import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../constants/map_constants.dart';
import '../../services/track_service.dart';
import 'truck_marker.dart';

/// Map widget specifically for truck drivers to see their own location
class DriverMapWidget extends StatefulWidget {
  const DriverMapWidget({super.key});

  @override
  State<DriverMapWidget> createState() => _DriverMapWidgetState();
}

class _DriverMapWidgetState extends State<DriverMapWidget> {
  final MapController _mapController = MapController();
  final TrackService _trackService = TrackService();

  LatLng? _driverLocation;
  bool _locationPermissionGranted = false;
  double _currentHeading = 0.0;
  bool _followDriver = true;
  bool _rotateWithCompass = true;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    // Start tracking driver's own location
    final permissionGranted = await _trackService.startUserTracking();
    if (mounted) {
      setState(() {
        _locationPermissionGranted = permissionGranted;
      });
    }

    if (!permissionGranted) {
      return;
    }

    // Listen to driver's location updates and continuously follow
    _trackService.userLocationStream.listen((location) {
      if (mounted) {
        setState(() {
          _driverLocation = location;
        });
        // Continuously center map on driver location as they move (Google Maps style)
        if (_driverLocation != null && _followDriver) {
          _mapController.move(
            _driverLocation!,
            _mapController.camera.zoom,
          );
        }
      }
    });

    // Listen to compass for rotation (gyroscope-like behavior)
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && _rotateWithCompass && event.heading != null) {
        setState(() {
          _currentHeading = event.heading!;
        });
        // Rotate map based on device orientation
        if (_driverLocation != null && _followDriver) {
          _mapController.rotate(-_currentHeading);
        }
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _trackService.stopUserTracking();
    super.dispose();
  }

  void _toggleCompassRotation() {
    setState(() {
      _rotateWithCompass = !_rotateWithCompass;
      if (!_rotateWithCompass) {
        // Reset rotation to north
        _mapController.rotate(0);
      }
    });
  }

  void _recenterMap() {
    if (_driverLocation != null) {
      _mapController.move(_driverLocation!, 16.0);
      setState(() {
        _followDriver = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationPermissionGranted) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surfaceWhite,
          boxShadow: [
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Location Permission Required',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enable location services to see your location on the map',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
        child: Stack(
          children: [
            FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _driverLocation ?? MapConstants.tagbilaranCenter,
            initialZoom: 16.0,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onPositionChanged: (position, hasGesture) {
              // Disable auto-follow if driver manually moves the map
              if (hasGesture && _followDriver) {
                setState(() {
                  _followDriver = false;
                });
              }
            },
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: MapConstants.osmTileUrl,
              userAgentPackageName: 'com.example.green_tabiliran',
              maxNativeZoom: 19,
            ),

            // Driver's own location marker (truck stays flat, arrow rotates)
            if (_driverLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: _driverLocation!,
                    child: TruckMarker(
                      size: 50.0,
                      heading: _rotateWithCompass ? _currentHeading : 0,
                      showDirection: true,
                    ),
                  ),
                ],
              ),
          ],
        ),
            
            // Floating action buttons for map controls
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Recenter button
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.pureWhite,
                    onPressed: _recenterMap,
                    child: Icon(
                      Icons.my_location,
                      color: _followDriver ? AppColors.primaryGreen : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Compass rotation toggle
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: AppColors.pureWhite,
                    onPressed: _toggleCompassRotation,
                    child: Icon(
                      Icons.explore,
                      color: _rotateWithCompass ? AppColors.primaryGreen : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
