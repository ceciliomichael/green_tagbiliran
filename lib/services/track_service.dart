import 'dart:async';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../constants/map_constants.dart';

class TrackService {
  static final TrackService _instance = TrackService._internal();
  factory TrackService() => _instance;
  TrackService._internal();
  
  // Stream controller for truck position updates
  final StreamController<LatLng> _truckPositionController = StreamController<LatLng>.broadcast();
  Stream<LatLng> get truckPositionStream => _truckPositionController.stream;
  
  // Stream controller for route progress updates
  final StreamController<List<LatLng>> _routeProgressController = StreamController<List<LatLng>>.broadcast();
  Stream<List<LatLng>> get routeProgressStream => _routeProgressController.stream;
  
  // Current truck position
  LatLng _currentPosition = MapConstants.currentTruckPosition;
  LatLng get currentPosition => _currentPosition;
  
  // Route simulation variables
  Timer? _simulationTimer;
  int _currentRouteIndex = 0;
  final List<LatLng> _completedRoute = [];
  
  // Initialize tracking service
  void startTracking() {
    _simulateMovement();
  }
  
  void stopTracking() {
    _simulationTimer?.cancel();
  }
  
  // Simulate truck movement along the route
  void _simulateMovement() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentRouteIndex < MapConstants.garbageCollectionRoute.length) {
        // Move to next point in route
        _currentPosition = MapConstants.garbageCollectionRoute[_currentRouteIndex];
        _completedRoute.add(_currentPosition);
        
        // Add some randomness to make movement more realistic
        final random = Random();
        final latOffset = (random.nextDouble() - 0.5) * 0.001; // Small random offset
        final lngOffset = (random.nextDouble() - 0.5) * 0.001;
        
        _currentPosition = LatLng(
          _currentPosition.latitude + latOffset,
          _currentPosition.longitude + lngOffset,
        );
        
        // Emit updates
        _truckPositionController.add(_currentPosition);
        _routeProgressController.add(List.from(_completedRoute));
        
        _currentRouteIndex++;
      } else {
        // Route completed, restart from beginning
        _currentRouteIndex = 0;
        _completedRoute.clear();
      }
    });
  }
  
  // Get estimated time to reach user's location
  Duration getEstimatedArrivalTime(LatLng userLocation) {
    final Distance distance = Distance();
    final distanceInMeters = distance.as(LengthUnit.Meter, _currentPosition, userLocation);
    
    // Assume average speed of 20 km/h for garbage truck
    final averageSpeedKmh = 20.0;
    final averageSpeedMs = averageSpeedKmh * 1000 / 3600; // Convert to m/s
    
    final timeInSeconds = distanceInMeters / averageSpeedMs;
    return Duration(seconds: timeInSeconds.round());
  }
  
  // Get remaining route points
  List<LatLng> getRemainingRoute() {
    if (_currentRouteIndex >= MapConstants.garbageCollectionRoute.length) {
      return [];
    }
    return MapConstants.garbageCollectionRoute.sublist(_currentRouteIndex);
  }
  
  // Get completed route points
  List<LatLng> getCompletedRoute() {
    return List.from(_completedRoute);
  }
  
  // Clean up resources
  void dispose() {
    _simulationTimer?.cancel();
    _truckPositionController.close();
    _routeProgressController.close();
  }
}
