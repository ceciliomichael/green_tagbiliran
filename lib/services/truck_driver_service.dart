import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/supabase_config.dart';

class TruckDriverResult {
  final bool success;
  final String? error;
  final String? message;
  final dynamic data;

  TruckDriverResult({
    required this.success,
    this.error,
    this.message,
    this.data,
  });
}

/// Service for managing truck driver accounts
class TruckDriverService {
  static final TruckDriverService _instance = TruckDriverService._internal();
  factory TruckDriverService() => _instance;
  TruckDriverService._internal();

  /// Create truck driver account (admin function)
  /// Only 1 truck driver per barangay allowed
  /// Name is auto-generated as "Truck Driver for {barangay}"
  Future<TruckDriverResult> createTruckDriver({
    required String phone,
    required String password,
    required String barangay,
  }) async {
    try {
      // Validate input
      if (phone.trim().isEmpty || !phone.startsWith('+63')) {
        return TruckDriverResult(
          success: false,
          error: 'Valid Philippine phone number is required',
        );
      }

      if (password.length < 6) {
        return TruckDriverResult(
          success: false,
          error: 'Password must be at least 6 characters',
        );
      }

      // Prepare request body for truck driver creation
      final requestBody = {
        'p_phone': phone.trim(),
        'p_password': password,
        'p_barangay': barangay,
        'p_user_role': 'truck_driver',
      };

      // Make HTTP request to create truck driver function
      final response = await http.post(
        Uri.parse(SupabaseConfig.createTruckDriverEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return TruckDriverResult(
            success: true,
            message:
                responseData['message'] ??
                'Truck driver account created successfully',
          );
        } else {
          return TruckDriverResult(
            success: false,
            error:
                responseData['error'] ??
                'Failed to create truck driver account',
          );
        }
      } else {
        return TruckDriverResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TruckDriverResult(
        success: false,
        error: 'Failed to create truck driver account: ${e.toString()}',
      );
    }
  }

  /// Get all truck drivers
  Future<TruckDriverResult> getAllTruckDrivers() async {
    try {
      final response = await http.post(
        Uri.parse(SupabaseConfig.getAllTruckDriversEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return TruckDriverResult(
            success: true,
            data: responseData['drivers'] ?? [],
            message: jsonEncode(responseData['drivers'] ?? []),
          );
        } else {
          return TruckDriverResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get truck drivers',
          );
        }
      } else {
        return TruckDriverResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TruckDriverResult(
        success: false,
        error: 'Failed to get truck drivers: ${e.toString()}',
      );
    }
  }

  /// Update truck driver
  /// Name is auto-updated based on barangay
  Future<TruckDriverResult> updateTruckDriver({
    required String driverId,
    required String phone,
    required String barangay,
  }) async {
    try {
      final requestBody = {
        'p_driver_id': driverId,
        'p_phone': phone.trim(),
        'p_barangay': barangay,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.updateTruckDriverEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return TruckDriverResult(
            success: true,
            message:
                responseData['message'] ?? 'Truck driver updated successfully',
          );
        } else {
          return TruckDriverResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update truck driver',
          );
        }
      } else {
        return TruckDriverResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TruckDriverResult(
        success: false,
        error: 'Failed to update truck driver: ${e.toString()}',
      );
    }
  }

  /// Reset truck driver password
  Future<TruckDriverResult> resetTruckDriverPassword({
    required String driverId,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 6) {
        return TruckDriverResult(
          success: false,
          error: 'Password must be at least 6 characters',
        );
      }

      final requestBody = {
        'p_driver_id': driverId,
        'p_new_password': newPassword,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.resetTruckDriverPasswordEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return TruckDriverResult(
            success: true,
            message: responseData['message'] ?? 'Password reset successfully',
          );
        } else {
          return TruckDriverResult(
            success: false,
            error: responseData['error'] ?? 'Failed to reset password',
          );
        }
      } else {
        return TruckDriverResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TruckDriverResult(
        success: false,
        error: 'Failed to reset password: ${e.toString()}',
      );
    }
  }

  /// Delete truck driver
  Future<TruckDriverResult> deleteTruckDriver(String driverId) async {
    try {
      final requestBody = {'p_driver_id': driverId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.deleteTruckDriverEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return TruckDriverResult(
            success: true,
            message:
                responseData['message'] ?? 'Truck driver deleted successfully',
          );
        } else {
          return TruckDriverResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete truck driver',
          );
        }
      } else {
        return TruckDriverResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TruckDriverResult(
        success: false,
        error: 'Failed to delete truck driver: ${e.toString()}',
      );
    }
  }
}

