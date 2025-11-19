import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../constants/map_constants.dart';
import '../../widgets/track/driver_map_widget.dart';
import '../../services/auth_service.dart';
import '../../services/status_tracking_service.dart';
import '../../services/track_service.dart';
import '../../services/gps_location_service.dart';
import '../../models/user.dart';
import '../../models/driver_status.dart';
import '../../widgets/ui/truck_driver_header.dart';
import '../../widgets/ui/truck_driver_location_status_card.dart';
import '../../widgets/ui/truck_driver_route_status_card.dart';
import '../../widgets/ui/truck_driver_action_button.dart';
import '../../widgets/ui/truck_driver_route_setup_dialog.dart';
import '../../widgets/ui/truck_driver_route_info.dart';
import '../../widgets/status/driver_status_update_card.dart';

class TruckDriverMainScreen extends StatefulWidget {
  const TruckDriverMainScreen({super.key});

  @override
  State<TruckDriverMainScreen> createState() => _TruckDriverMainScreenState();
}

class _TruckDriverMainScreenState extends State<TruckDriverMainScreen> {
  bool _isRouteActive = false;
  bool _isLocationDetected = false;
  bool _isDetectingLocation = false;
  String? _startLocation;
  String? _endLocation;
  LatLng? _currentPosition;

  final _authService = AuthService();
  final _statusTrackingService = StatusTrackingService();
  final _trackService = TrackService();
  final _gpsService = GpsLocationService();
  User? _currentUser;
  String _assignedBarangay = 'Loading...';
  String _driverName = 'Driver';
  DriverStatusRecord? _currentStatus;
  Timer? _locationUpdateTimer;
  
  // Feature flag for new status tracking (disabled - using GPS tracking)
  final bool _useStatusTracking = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _detectCurrentLocation();
  }

  Future<void> _loadUserData() async {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      setState(() {
        _assignedBarangay = _currentUser!.barangay;
        _driverName = _currentUser!.firstName;
      });
      
      // Load current status if using status tracking
      if (_useStatusTracking) {
        _loadCurrentStatus();
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  Future<void> _loadCurrentStatus() async {
    if (_currentUser != null) {
      final status = await _statusTrackingService.getLatestForBarangay(
        _currentUser!.barangay,
      );
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    // Start GPS tracking to get real location
    final started = await _gpsService.startTracking();
    
    if (started) {
      // Listen to location updates
      _gpsService.locationStream.listen((location) {
        if (mounted) {
          setState(() {
            _currentPosition = location;
            _startLocation =
                'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
          });
        }
      });

      // Wait for initial location
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
          _isLocationDetected = _currentPosition != null;
        });
      }
      
      // Stop GPS initially (will restart when route starts)
      _gpsService.stopTracking();
    } else {
      // Fallback to center if GPS fails
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
          _isLocationDetected = true;
          _currentPosition = MapConstants.tagbilaranCenter;
          _startLocation =
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}';
        });
      }
    }
  }

  Widget _buildMapWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const DriverMapWidget(),
      ),
    );
  }

  void _showRouteSetupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TruckDriverRouteSetupDialog(
          assignedBarangay: _assignedBarangay,
          onStartRoute: _startRoute,
        );
      },
    );
  }

  Future<void> _startRoute(String endLocation) async {
    setState(() {
      _isRouteActive = true;
      _endLocation = endLocation;
    });

    // Start GPS tracking
    await _gpsService.startTracking();
    
    // Listen to location updates and update display in real-time
    _gpsService.locationStream.listen((location) {
      if (mounted) {
        setState(() {
          _currentPosition = location;
          // Update the displayed location in real-time
          _startLocation =
              'Lat: ${location.latitude.toStringAsFixed(6)}, Lng: ${location.longitude.toStringAsFixed(6)}';
        });
      }
    });

    // Send location updates to database every 5 seconds
    if (_currentUser != null) {
      // Send immediate update first
      if (_currentPosition != null) {
        developer.log('🚀 Sending initial driver location to database...', name: 'DriverLocation');
        _trackService.updateDriverLocation(
          driverId: _currentUser!.id,
          driverName: '${_currentUser!.firstName} ${_currentUser!.lastName}',
          barangay: _currentUser!.barangay,
          position: _currentPosition!,
          isActive: true,
        ).then((success) {
          if (success) {
            developer.log('✅ Initial location sent successfully', name: 'DriverLocation');
          } else {
            developer.log('❌ Failed to send initial location', name: 'DriverLocation');
          }
        });
      }
      
      // Set up periodic updates every 5 seconds (even if not moving)
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        if (_isRouteActive && _currentUser != null) {
          // Get latest position
          final position = _gpsService.currentLocation ?? _currentPosition;
          
          if (position != null) {
            developer.log('📡 Sending periodic location update...', name: 'DriverLocation');
            final success = await _trackService.updateDriverLocation(
              driverId: _currentUser!.id,
              driverName: '${_currentUser!.firstName} ${_currentUser!.lastName}',
              barangay: _currentUser!.barangay,
              position: position,
              isActive: true,
            );
            
            if (!success) {
              developer.log('❌ Failed to update driver location', name: 'DriverLocation');
            }
          } else {
            developer.log('⚠️ No GPS position available yet', name: 'DriverLocation');
          }
        }
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Route started to $endLocation, $_assignedBarangay'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _endRoute() async {
    // Stop GPS tracking
    _gpsService.stopTracking();
    
    // Cancel location update timer
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    
    // Send final update marking driver as inactive
    if (_currentUser != null && _currentPosition != null) {
      await _trackService.updateDriverLocation(
        driverId: _currentUser!.id,
        driverName: '${_currentUser!.firstName} ${_currentUser!.lastName}',
        barangay: _currentUser!.barangay,
        position: _currentPosition!,
        isActive: false,
      );
    }

    setState(() {
      _isRouteActive = false;
      _endLocation = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Route completed successfully'),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _gpsService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              TruckDriverHeader(
                driverName: _driverName,
                assignedBarangay: _assignedBarangay,
                isRouteActive: _useStatusTracking 
                    ? (_currentStatus?.status != DriverStatus.completed && 
                       _currentStatus?.status != null)
                    : _isRouteActive,
                onLogout: _logout,
              ),
              const SizedBox(height: 16),
              
              if (_useStatusTracking)
                _buildStatusTrackingContent()
              else
                _buildMapTrackingContent(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTrackingContent() {
    if (_currentUser == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      );
    }

    return Column(
      children: [
        // Status update card with stepper buttons
        DriverStatusUpdateCard(
          driverId: _currentUser!.id,
          assignedBarangay: _assignedBarangay,
          currentStatus: _currentStatus,
          onStatusUpdated: _loadCurrentStatus,
        ),
        const SizedBox(height: 24),
        const TruckDriverRouteInfo(),
      ],
    );
  }

  Widget _buildMapTrackingContent() {
    return Column(
      children: [
        TruckDriverLocationStatusCard(
          isLocationDetected: _isLocationDetected,
          isDetectingLocation: _isDetectingLocation,
          startLocation: _startLocation,
          onRefresh: _detectCurrentLocation,
        ),
        const SizedBox(height: 16),
        _buildMapWidget(),
        TruckDriverRouteStatusCard(
          isRouteActive: _isRouteActive,
          endLocation: _endLocation,
          assignedBarangay: _assignedBarangay,
        ),
        const SizedBox(height: 24),
        if (!_isRouteActive) ...[
          TruckDriverActionButton(
            text: 'Start Route',
            icon: Icons.play_arrow,
            onPressed: _showRouteSetupDialog,
            isDisabled: !_isLocationDetected,
          ),
        ] else ...[
          TruckDriverActionButton(
            text: 'End Route',
            icon: Icons.stop,
            onPressed: _endRoute,
            isDestructive: true,
          ),
        ],
        const SizedBox(height: 24),
        const TruckDriverRouteInfo(),
      ],
    );
  }
}

