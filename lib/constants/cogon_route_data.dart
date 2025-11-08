import 'package:latlong2/latlong.dart';

/// Route data for Cogon barangay garbage collection
class CogonRouteData {
  // Route waypoints with actual coordinates for Cogon, Tagbilaran
  static final List<RouteWaypoint> waypoints = [
    // Start: City Hall
    RouteWaypoint(
      name: 'Tagbilaran City Hall',
      position: const LatLng(9.6477, 123.8537),
      description: 'Starting point',
      statusPhase: 0, // not_started
    ),
    
    // Northern Cogon
    RouteWaypoint(
      name: 'C.P. Garcia Avenue',
      position: const LatLng(9.6490, 123.8540),
      description: 'Main entry to Cogon',
      statusPhase: 1, // heading_to_barangay
    ),
    RouteWaypoint(
      name: 'Calceta Street - Rizal Street',
      position: const LatLng(9.6505, 123.8545),
      description: 'Northern residential area',
      statusPhase: 1,
    ),
    RouteWaypoint(
      name: 'Hangos Street',
      position: const LatLng(9.6515, 123.8550),
      description: 'Collection point',
      statusPhase: 1,
    ),
    RouteWaypoint(
      name: 'F. Torralba Street',
      position: const LatLng(9.6520, 123.8555),
      description: 'Near Cogon Health Center',
      statusPhase: 1,
    ),
    
    // Central Cogon (Residential Core)
    RouteWaypoint(
      name: 'B. Inting Street',
      position: const LatLng(9.6510, 123.8560),
      description: 'Residential core',
      statusPhase: 2, // arrived_at_barangay
    ),
    RouteWaypoint(
      name: 'Mariano Parras Street',
      position: const LatLng(9.6500, 123.8565),
      description: 'Residential collection',
      statusPhase: 2,
    ),
    RouteWaypoint(
      name: 'Enerio Street',
      position: const LatLng(9.6495, 123.8570),
      description: 'Narrow residential street',
      statusPhase: 2,
    ),
    RouteWaypoint(
      name: 'F. Rocha Street',
      position: const LatLng(9.6490, 123.8575),
      description: 'Residential area',
      statusPhase: 2,
    ),
    
    // South Cogon (Downtown Edge)
    RouteWaypoint(
      name: 'Tamblot Street',
      position: const LatLng(9.6480, 123.8580),
      description: 'Downtown edge',
      statusPhase: 2,
    ),
    RouteWaypoint(
      name: 'J. Borja Street',
      position: const LatLng(9.6475, 123.8585),
      description: 'Commercial district',
      statusPhase: 2,
    ),
    RouteWaypoint(
      name: 'Palma Street',
      position: const LatLng(9.6470, 123.8590),
      description: 'Downtown collection',
      statusPhase: 2,
    ),
    RouteWaypoint(
      name: 'C. Putong Street',
      position: const LatLng(9.6465, 123.8595),
      description: 'Commercial area',
      statusPhase: 2,
    ),
    
    // West Cogon (Market and Coastal Zone)
    RouteWaypoint(
      name: 'Celestino Gallares Street',
      position: const LatLng(9.6460, 123.8600),
      description: 'Market approach',
      statusPhase: 3, // completed
    ),
    RouteWaypoint(
      name: 'Cogon Commercial - Belderol',
      position: const LatLng(9.6455, 123.8605),
      description: 'Commercial zone',
      statusPhase: 3,
    ),
    RouteWaypoint(
      name: 'Cogon Market',
      position: const LatLng(9.6450, 123.8610),
      description: 'Market waste collection',
      statusPhase: 3,
    ),
    RouteWaypoint(
      name: 'Pamaong Street',
      position: const LatLng(9.6445, 123.8615),
      description: 'Market area',
      statusPhase: 3,
    ),
    
    // Final Sweep
    RouteWaypoint(
      name: 'Metrobank Cogon',
      position: const LatLng(9.6440, 123.8620),
      description: 'Final collection area',
      statusPhase: 3,
    ),
    RouteWaypoint(
      name: 'Cogon Bus Terminal',
      position: const LatLng(9.6435, 123.8625),
      description: 'End point',
      statusPhase: 3,
    ),
  ];

  /// Get all positions for polyline
  static List<LatLng> get routePolyline {
    return waypoints.map((w) => w.position).toList();
  }

  /// Get waypoints for a specific status phase
  /// 0 = not_started, 1 = heading_to, 2 = arrived, 3 = completed
  static List<RouteWaypoint> getWaypointsForPhase(int phase) {
    return waypoints.where((w) => w.statusPhase <= phase).toList();
  }

  /// Get current position marker based on status phase
  static LatLng getPositionForPhase(int phase) {
    final phaseWaypoints = waypoints.where((w) => w.statusPhase == phase).toList();
    if (phaseWaypoints.isEmpty) {
      return waypoints.first.position;
    }
    // Return middle waypoint of the phase
    return phaseWaypoints[phaseWaypoints.length ~/ 2].position;
  }

  /// Get route center point for map
  static LatLng getRouteCenter() {
    double totalLat = 0;
    double totalLng = 0;

    for (final waypoint in waypoints) {
      totalLat += waypoint.position.latitude;
      totalLng += waypoint.position.longitude;
    }

    return LatLng(
      totalLat / waypoints.length,
      totalLng / waypoints.length,
    );
  }

  /// Street names for display
  static const List<String> streetNames = [
    'C.P. Garcia Avenue',
    'Calceta Street',
    'F. Torralba Street',
    'Hangos Street',
    'B. Inting Street',
    'Mariano Parras Street',
    'Enerio Street',
    'F. Rocha Street',
    'Tamblot Street',
    'J. Borja Street',
    'Palma Street',
    'C. Putong Street',
    'Celestino Gallares Street',
    'Pamaong Street',
  ];
}

/// Waypoint model for route visualization
class RouteWaypoint {
  final String name;
  final LatLng position;
  final String description;
  final int statusPhase; // 0=not_started, 1=heading, 2=arrived, 3=completed

  const RouteWaypoint({
    required this.name,
    required this.position,
    required this.description,
    required this.statusPhase,
  });
}

