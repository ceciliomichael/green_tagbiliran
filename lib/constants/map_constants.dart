import 'package:latlong2/latlong.dart';

class MapConstants {
  // Tagbiliran City center coordinates
  static const LatLng tagbiliranCenter = LatLng(9.647, 123.854);

  // Initial map zoom level
  static const double initialZoom = 14.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 10.0;

  // OpenStreetMap tile URL
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // Sample garbage collection route points around Tagbiliran
  static final List<LatLng> garbageCollectionRoute = [
    const LatLng(9.640, 123.850), // Starting point near port area
    const LatLng(9.642, 123.852), // City center direction
    const LatLng(9.645, 123.855), // Main residential area
    const LatLng(9.648, 123.857), // Commercial district
    const LatLng(9.650, 123.859), // North residential
    const LatLng(9.652, 123.856), // Turn back south
    const LatLng(9.649, 123.853), // Central market area
    const LatLng(9.646, 123.851), // Government center
    const LatLng(9.644, 123.849), // School district
    const LatLng(9.641, 123.848), // Return to depot
  ];

  // Truck current position (simulated)
  static const LatLng currentTruckPosition = LatLng(9.645, 123.855);

  // Route colors
  static const int routeColorValue = 0xFF6BA644; // Primary green
  static const int completedRouteColorValue = 0xFF81C784; // Success green
  static const int pendingRouteColorValue = 0xFF9E9E9E; // Text hint gray
}
