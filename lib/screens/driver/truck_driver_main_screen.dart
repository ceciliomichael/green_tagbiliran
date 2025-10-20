import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../constants/map_constants.dart';
import '../../widgets/track/map_widget.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../widgets/ui/truck_driver_header.dart';
import '../../widgets/ui/truck_driver_location_status_card.dart';
import '../../widgets/ui/truck_driver_route_status_card.dart';
import '../../widgets/ui/truck_driver_action_button.dart';
import '../../widgets/ui/truck_driver_route_setup_dialog.dart';
import '../../widgets/ui/truck_driver_route_info.dart';

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
  User? _currentUser;
  String _assignedBarangay = 'Loading...';
  String _driverName = 'Driver';

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
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _detectCurrentLocation() {
    setState(() {
      _isDetectingLocation = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
          _isLocationDetected = true;
          _currentPosition = MapConstants.tagbilaranCenter;
          _startLocation =
              'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}';
        });
      }
    });
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
        child: const MapWidget(),
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

  void _startRoute(String endLocation) {
    setState(() {
      _isRouteActive = true;
      _endLocation = endLocation;
    });

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

  void _endRoute() {
    setState(() {
      _isRouteActive = false;
      _endLocation = null;
    });

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
                isRouteActive: _isRouteActive,
                onLogout: _logout,
              ),
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

