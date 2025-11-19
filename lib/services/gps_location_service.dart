import 'dart:async';
import 'dart:developer' as developer;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Model for location data with heading
class LocationData {
  final LatLng position;
  final double heading; // Direction in degrees (0-360)
  final double speed; // Speed in m/s
  
  LocationData({
    required this.position,
    required this.heading,
    required this.speed,
  });
}

/// Service for managing real-time GPS location tracking
class GpsLocationService {
  static final GpsLocationService _instance = GpsLocationService._internal();
  factory GpsLocationService() => _instance;
  GpsLocationService._internal();

  // Stream controller for location updates
  final StreamController<LatLng> _locationController =
      StreamController<LatLng>.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;
  
  // Stream controller for location data with heading
  final StreamController<LocationData> _locationDataController =
      StreamController<LocationData>.broadcast();
  Stream<LocationData> get locationDataStream => _locationDataController.stream;

  // Current location
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;
  
  // Current heading (direction)
  double _currentHeading = 0.0;
  double get currentHeading => _currentHeading;

  // Location tracking subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permissions
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permissions
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Initialize and start tracking location
  Future<bool> startTracking() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check permissions
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Get current position first with best accuracy
      developer.log('📍 Getting initial GPS location with high accuracy...', name: 'GpsLocationService');
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, // Use BEST accuracy instead of high
          timeLimit: Duration(seconds: 10), // Wait up to 10 seconds for accurate fix
        ),
      );
      
      developer.log('✅ Got GPS location: (${position.latitude}, ${position.longitude}) - Accuracy: ${position.accuracy}m', name: 'GpsLocationService');

      _currentLocation = LatLng(position.latitude, position.longitude);
      _currentHeading = position.heading;
      _locationController.add(_currentLocation!);
      _locationDataController.add(LocationData(
        position: _currentLocation!,
        heading: _currentHeading,
        speed: position.speed,
      ));

      // Start listening to position updates with best accuracy
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, // Best for navigation/driving
        distanceFilter: 0, // Update on any movement (no distance filter)
      );

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position position) {
        developer.log('📍 GPS Update: (${position.latitude}, ${position.longitude}) - Accuracy: ${position.accuracy}m', name: 'GpsLocationService');
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentHeading = position.heading;
        _locationController.add(_currentLocation!);
        _locationDataController.add(LocationData(
          position: _currentLocation!,
          heading: _currentHeading,
          speed: position.speed,
        ));
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Stop tracking location
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  // Get distance between two points in meters
  double getDistance(LatLng from, LatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  // Calculate estimated time to reach destination
  Duration getEstimatedArrivalTime(LatLng from, LatLng to,
      {double averageSpeedKmh = 20.0}) {
    final distanceInMeters = getDistance(from, to);
    final averageSpeedMs = averageSpeedKmh * 1000 / 3600;
    final timeInSeconds = distanceInMeters / averageSpeedMs;
    return Duration(seconds: timeInSeconds.round());
  }

  // Clean up resources
  void dispose() {
    stopTracking();
    _locationController.close();
    _locationDataController.close();
  }
}
