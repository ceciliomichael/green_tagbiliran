import 'package:latlong2/latlong.dart';
import 'gps_location_service.dart';
import 'driver_location_service.dart';

/// Service for tracking user and driver locations in real-time
class TrackService {
  static final TrackService _instance = TrackService._internal();
  factory TrackService() => _instance;
  TrackService._internal();

  final GpsLocationService _gpsService = GpsLocationService();
  final DriverLocationService _driverService = DriverLocationService();

  // Get user location stream
  Stream<LatLng> get userLocationStream => _gpsService.locationStream;

  // Get driver locations stream
  Stream<List<DriverLocation>> get driverLocationsStream =>
      _driverService.driversStream;

  // Get current user location
  LatLng? get currentUserLocation => _gpsService.currentLocation;

  /// Start tracking user location
  Future<bool> startUserTracking() async {
    return await _gpsService.startTracking();
  }

  /// Stop tracking user location
  void stopUserTracking() {
    _gpsService.stopTracking();
  }

  /// Start watching drivers for a specific barangay
  void startWatchingDrivers(String barangay) {
    _driverService.startWatchingBarangay(barangay);
  }

  /// Stop watching drivers
  void stopWatchingDrivers() {
    _driverService.stopWatching();
  }

  /// Update driver location (for driver app)
  Future<bool> updateDriverLocation({
    required String driverId,
    required String driverName,
    required String barangay,
    required LatLng position,
    required bool isActive,
  }) async {
    return await _driverService.updateDriverLocation(
      driverId: driverId,
      driverName: driverName,
      barangay: barangay,
      position: position,
      isActive: isActive,
    );
  }

  /// Get estimated arrival time from driver to user
  Duration getEstimatedArrivalTime(LatLng driverLocation, LatLng userLocation) {
    return _gpsService.getEstimatedArrivalTime(
      driverLocation,
      userLocation,
      averageSpeedKmh: 20.0,
    );
  }

  /// Get distance between two points in meters
  double getDistance(LatLng from, LatLng to) {
    return _gpsService.getDistance(from, to);
  }

  /// Get active drivers for barangay
  List<DriverLocation> getActiveDriversForBarangay(String barangay) {
    return _driverService.getActiveDriversForBarangay(barangay);
  }

  /// Mark driver as inactive (when device is turned off)
  Future<bool> markDriverInactive(String driverId) async {
    return await _driverService.markDriverInactive(driverId);
  }

  /// Remove driver location completely (when device is disconnected)
  Future<bool> removeDriverLocation(String driverId) async {
    return await _driverService.removeDriverLocation(driverId);
  }

  /// Clean up resources
  void dispose() {
    _gpsService.dispose();
    _driverService.dispose();
  }
}
