import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../constants/supabase_config.dart';

/// Model for driver location data
class DriverLocation {
  final String driverId;
  final String driverName;
  final String barangay;
  final LatLng position;
  final DateTime lastUpdated;
  final bool isActive;

  DriverLocation({
    required this.driverId,
    required this.driverName,
    required this.barangay,
    required this.position,
    required this.lastUpdated,
    required this.isActive,
  });

  factory DriverLocation.fromJson(Map<String, dynamic> json) {
    return DriverLocation(
      driverId: json['driver_id'] as String,
      driverName: json['driver_name'] as String,
      barangay: json['barangay'] as String,
      position: LatLng(
        json['latitude'] as double,
        json['longitude'] as double,
      ),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'driver_name': driverName,
      'barangay': barangay,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'last_updated': lastUpdated.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// Service for managing driver location tracking
class DriverLocationService {
  static final DriverLocationService _instance =
      DriverLocationService._internal();
  factory DriverLocationService() => _instance;
  DriverLocationService._internal();

  // Stream controller for driver locations
  final StreamController<List<DriverLocation>> _driversController =
      StreamController<List<DriverLocation>>.broadcast();
  Stream<List<DriverLocation>> get driversStream => _driversController.stream;

  // Cache of driver locations
  final Map<String, DriverLocation> _driverLocations = {};

  // Timer for polling driver locations
  Timer? _pollingTimer;

  /// Start watching driver locations for a specific barangay
  void startWatchingBarangay(String barangay) {
    // Stop any existing polling
    stopWatching();

    // Start polling every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchDriverLocations(barangay);
    });

    // Fetch immediately
    _fetchDriverLocations(barangay);
  }

  /// Fetch driver locations from Supabase database
  Future<void> _fetchDriverLocations(String barangay) async {
    try {
      // Query Supabase REST API for active drivers in the barangay
      final url = Uri.parse(
        '${SupabaseConfig.url}/rest/v1/driver_locations?barangay=eq.$barangay&is_active=eq.true&select=*',
      );

      final response = await http.get(url, headers: SupabaseConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        developer.log('✅ Fetched ${data.length} active drivers for $barangay', name: 'DriverLocationService');
        
        // Clear old locations for this barangay
        _driverLocations.removeWhere((key, value) => value.barangay == barangay);
        
        // Update cache with fresh data
        for (final item in data) {
          final driver = DriverLocation.fromJson(item);
          _driverLocations[driver.driverId] = driver;
          developer.log('  📍 Driver: ${driver.driverName} at (${driver.position.latitude}, ${driver.position.longitude})', name: 'DriverLocationService');
        }
        
        // Emit updated list
        _driversController.add(_driverLocations.values.toList());
      } else {
        developer.log('❌ Failed to fetch drivers: ${response.statusCode} - ${response.body}', name: 'DriverLocationService');
      }
    } catch (e) {
      // Handle error silently or log
      developer.log('❌ Error fetching driver locations: $e', name: 'DriverLocationService');
    }
  }

  /// Update driver location (called by driver app)
  Future<bool> updateDriverLocation({
    required String driverId,
    required String driverName,
    required String barangay,
    required LatLng position,
    required bool isActive,
  }) async {
    try {
      // Upsert to Supabase using UPSERT (POST with Prefer: resolution=merge-duplicates)
      final url = Uri.parse(
        '${SupabaseConfig.url}/rest/v1/driver_locations',
      );

      final body = jsonEncode({
        'driver_id': driverId,
        'driver_name': driverName,
        'barangay': barangay,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_active': isActive,
        'last_updated': DateTime.now().toIso8601String(),
      });

      final headers = {
        ...SupabaseConfig.headers,
        'Prefer': 'resolution=merge-duplicates',
      };

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('✅ Updated driver location: $driverName at ($barangay) - Active: $isActive', name: 'DriverLocationService');
        
        // Update local cache
        final driverLocation = DriverLocation(
          driverId: driverId,
          driverName: driverName,
          barangay: barangay,
          position: position,
          lastUpdated: DateTime.now(),
          isActive: isActive,
        );

        _driverLocations[driverId] = driverLocation;
        _driversController.add(_driverLocations.values.toList());

        return true;
      } else {
        developer.log('❌ Failed to update driver location: ${response.statusCode} - ${response.body}', name: 'DriverLocationService');
      }
      return false;
    } catch (e) {
      developer.log('❌ Error updating driver location: $e', name: 'DriverLocationService');
      return false;
    }
  }

  /// Get active drivers for a specific barangay
  List<DriverLocation> getActiveDriversForBarangay(String barangay) {
    return _driverLocations.values
        .where((driver) => driver.barangay == barangay && driver.isActive)
        .toList();
  }

  /// Mark driver as inactive (when device is turned off)
  Future<bool> markDriverInactive(String driverId) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.url}/rpc/mark_driver_inactive',
      );

      final body = jsonEncode({'p_driver_id': driverId});

      final response = await http.post(url, headers: SupabaseConfig.headers, body: body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          developer.log('✅ Driver $driverId marked as inactive', name: 'DriverLocationService');
          
          // Remove from local cache
          _driverLocations.remove(driverId);
          _driversController.add(_driverLocations.values.toList());
          
          return true;
        }
      }
      developer.log('❌ Failed to mark driver inactive: ${response.body}', name: 'DriverLocationService');
      return false;
    } catch (e) {
      developer.log('❌ Error marking driver inactive: $e', name: 'DriverLocationService');
      return false;
    }
  }

  /// Remove driver location completely (when device is disconnected)
  Future<bool> removeDriverLocation(String driverId) async {
    try {
      final url = Uri.parse(
        '${SupabaseConfig.url}/rpc/remove_driver_location',
      );

      final body = jsonEncode({'p_driver_id': driverId});

      final response = await http.post(url, headers: SupabaseConfig.headers, body: body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          developer.log('✅ Driver location removed for $driverId', name: 'DriverLocationService');
          
          // Remove from local cache
          _driverLocations.remove(driverId);
          _driversController.add(_driverLocations.values.toList());
          
          return true;
        }
      }
      developer.log('❌ Failed to remove driver location: ${response.body}', name: 'DriverLocationService');
      return false;
    } catch (e) {
      developer.log('❌ Error removing driver location: $e', name: 'DriverLocationService');
      return false;
    }
  }

  /// Stop watching driver locations
  void stopWatching() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Clean up resources
  void dispose() {
    stopWatching();
    _driversController.close();
    _driverLocations.clear();
  }
}
