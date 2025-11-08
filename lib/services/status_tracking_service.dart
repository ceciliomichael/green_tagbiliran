import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/supabase_config.dart';
import '../models/driver_status.dart';

/// Result wrapper for status tracking operations
class StatusTrackingResult {
  final bool success;
  final String? error;
  final String? message;
  final DriverStatusRecord? data;

  StatusTrackingResult({
    required this.success,
    this.error,
    this.message,
    this.data,
  });
}

/// Service for managing driver status tracking
class StatusTrackingService {
  static final StatusTrackingService _instance =
      StatusTrackingService._internal();
  factory StatusTrackingService() => _instance;
  StatusTrackingService._internal();

  // Stream controllers for real-time updates
  final Map<String, StreamController<DriverStatusRecord?>> _barangayControllers =
      {};
  final Map<String, Timer> _pollingTimers = {};

  /// Update driver status
  Future<StatusTrackingResult> updateStatus({
    required String driverId,
    required String barangay,
    required DriverStatus status,
    String? message,
  }) async {
    try {
      final requestBody = {
        'p_driver_id': driverId,
        'p_barangay': barangay,
        'p_status': status.value,
        'p_message': message,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.updateDriverStatusEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          DriverStatusRecord? record;
          if (responseData['data'] != null) {
            record = DriverStatusRecord.fromJson(
                responseData['data'] as Map<String, dynamic>);
          }

          return StatusTrackingResult(
            success: true,
            message: responseData['message'] as String? ??
                'Status updated successfully',
            data: record,
          );
        } else {
          return StatusTrackingResult(
            success: false,
            error: responseData['error'] as String? ?? 'Failed to update status',
          );
        }
      } else {
        return StatusTrackingResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return StatusTrackingResult(
        success: false,
        error: 'Failed to update status: ${e.toString()}',
      );
    }
  }

  /// Get latest driver status for a specific barangay
  Future<DriverStatusRecord?> getLatestForBarangay(String barangay) async {
    try {
      final requestBody = {
        'p_barangay': barangay,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.getDriverStatusForBarangayEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return DriverStatusRecord.fromJson(
              responseData['data'] as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get all current driver statuses (latest per barangay)
  Future<List<DriverStatusRecord>> getAllStatuses() async {
    try {
      final response = await http.post(
        Uri.parse(SupabaseConfig.getAllDriverStatusesEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'] as List<dynamic>;
          return dataList
              .map((item) =>
                  DriverStatusRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get driver's status history
  Future<List<DriverStatusRecord>> getDriverHistory({
    required String driverId,
    int limit = 10,
  }) async {
    try {
      final requestBody = {
        'p_driver_id': driverId,
        'p_limit': limit,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.getDriverStatusHistoryEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'] as List<dynamic>;
          return dataList
              .map((item) =>
                  DriverStatusRecord.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Watch barangay status with polling
  Stream<DriverStatusRecord?> watchBarangayStatus(
    String barangay, {
    Duration interval = const Duration(seconds: 15),
  }) {
    // Create or get existing controller for this barangay
    if (!_barangayControllers.containsKey(barangay)) {
      _barangayControllers[barangay] =
          StreamController<DriverStatusRecord?>.broadcast(
        onListen: () => _startPolling(barangay, interval),
        onCancel: () => _stopPolling(barangay),
      );
    }

    return _barangayControllers[barangay]!.stream;
  }

  /// Start polling for a barangay
  void _startPolling(String barangay, Duration interval) {
    // Cancel existing timer if any
    _stopPolling(barangay);

    // Fetch immediately
    _pollBarangayStatus(barangay);

    // Set up periodic polling
    _pollingTimers[barangay] = Timer.periodic(interval, (_) {
      _pollBarangayStatus(barangay);
    });
  }

  /// Stop polling for a barangay
  void _stopPolling(String barangay) {
    _pollingTimers[barangay]?.cancel();
    _pollingTimers.remove(barangay);
  }

  /// Poll status for a barangay
  Future<void> _pollBarangayStatus(String barangay) async {
    try {
      final status = await getLatestForBarangay(barangay);
      if (_barangayControllers.containsKey(barangay) &&
          !_barangayControllers[barangay]!.isClosed) {
        _barangayControllers[barangay]!.add(status);
      }
    } catch (e) {
      // Silently handle errors in polling
      if (_barangayControllers.containsKey(barangay) &&
          !_barangayControllers[barangay]!.isClosed) {
        _barangayControllers[barangay]!.add(null);
      }
    }
  }

  /// Clean up resources
  void dispose() {
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    for (final controller in _barangayControllers.values) {
      controller.close();
    }
    _barangayControllers.clear();
  }

  /// Stop watching a specific barangay
  void stopWatchingBarangay(String barangay) {
    _stopPolling(barangay);
    _barangayControllers[barangay]?.close();
    _barangayControllers.remove(barangay);
  }
}

