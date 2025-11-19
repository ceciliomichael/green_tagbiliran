import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../constants/map_constants.dart';
import '../../services/track_service.dart';
import '../../services/auth_service.dart';

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final MapController _mapController = MapController();
  final TrackService _trackService = TrackService();
  final AuthService _authService = AuthService();

  LatLng? _driverLocation;
  bool _isTracking = false;
  bool _locationPermissionGranted = false;
  Timer? _locationUpdateTimer;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permissionGranted = await _trackService.startUserTracking();
    
    if (mounted) {
      setState(() {
        _locationPermissionGranted = permissionGranted;
      });
    }

    if (permissionGranted) {
      // Listen to location updates
      _trackService.userLocationStream.listen((location) {
        if (mounted) {
          setState(() {
            _driverLocation = location;
          });
        }
      });

      // Wait a moment to get initial location, then stop
      await Future.delayed(const Duration(seconds: 2));
      
      // Stop tracking initially (driver must press Start)
      if (mounted && !_isTracking) {
        _trackService.stopUserTracking();
      }
    }
  }

  Future<void> _startTracking() async {
    final user = _authService.currentUser;
    if (user == null) return;

    // Start GPS tracking
    final started = await _trackService.startUserTracking();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start location tracking'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isTracking = true;
    });

    // Send location updates to backend every 5 seconds
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_driverLocation != null) {
        _trackService.updateDriverLocation(
          driverId: user.id,
          driverName: '${user.firstName} ${user.lastName}',
          barangay: user.barangay,
          position: _driverLocation!,
          isActive: true,
        );
      }
    });
  }

  void _pauseTracking() {
    final user = _authService.currentUser;
    if (user == null) return;

    // Stop GPS tracking
    _trackService.stopUserTracking();

    // Cancel timer
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    // Mark driver as inactive in the database
    _trackService.markDriverInactive(user.id);

    setState(() {
      _isTracking = false;
    });
  }

  @override
  void dispose() {
    final user = _authService.currentUser;
    
    // Cancel timer
    _locationUpdateTimer?.cancel();
    
    // Stop GPS tracking
    _trackService.stopUserTracking();
    
    // Mark driver as inactive when screen is disposed (device turned off/app closed)
    if (user != null && _isTracking) {
      _trackService.markDriverInactive(user.id);
    }
    
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Driver Tracking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isTracking ? 'Tracking Active' : 'Tracking Paused',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isTracking
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isTracking ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isTracking ? Icons.radio_button_checked : Icons.pause,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isTracking ? 'ACTIVE' : 'PAUSED',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isTracking ? null : _startTracking,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isTracking ? _pauseTracking : null,
              icon: const Icon(Icons.pause),
              label: const Text('Pause Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!_locationPermissionGranted) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              offset: const Offset(8, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'Location Permission Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _driverLocation ?? MapConstants.tagbilaranCenter,
            initialZoom: 15.0,
            minZoom: MapConstants.minZoom,
            maxZoom: MapConstants.maxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all, // Enable zoom, pan, rotate
            ),
          ),
          children: [
            // OpenStreetMap tile layer
            TileLayer(
              urlTemplate: MapConstants.osmTileUrl,
              userAgentPackageName: 'com.example.green_tabiliran',
              maxNativeZoom: 19,
            ),

            // Driver location marker
            if (_driverLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 60.0,
                    height: 60.0,
                    point: _driverLocation!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isTracking
                            ? AppColors.primaryGreen
                            : Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.pureWhite,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isTracking
                                    ? AppColors.primaryGreen
                                    : Colors.orange)
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: AppColors.pureWhite,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildControlButtons(),
              const SizedBox(height: 20),
              _buildMap(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
