import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constants/supabase_config.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? message;

  AuthResult({required this.success, this.error, this.user, this.message});
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user state
  User? _currentUser;
  User? get currentUser => _currentUser;

  // Session management
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'access_token';

  // Initialize auth service and restore session
  Future<void> initialize() async {
    await _restoreSession();
  }

  // Register a new user
  Future<AuthResult> registerUser({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String barangay,
  }) async {
    try {
      // Validate input
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult(
          success: false,
          error: 'First name and last name are required',
        );
      }

      if (phone.trim().isEmpty || !phone.startsWith('+63')) {
        return AuthResult(
          success: false,
          error: 'Valid Philippine phone number is required',
        );
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          error: 'Password must be at least 6 characters',
        );
      }

      // Prepare request body
      final requestBody = {
        'p_first_name': firstName.trim(),
        'p_last_name': lastName.trim(),
        'p_phone': phone.trim(),
        'p_password': password,
        'p_barangay': barangay,
      };

      // Make HTTP request to register function
      final response = await http.post(
        Uri.parse(SupabaseConfig.registerUserEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return AuthResult(success: true, message: responseData['message']);
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Registration failed',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Create truck driver account (admin function)
  Future<AuthResult> createTruckDriverAccount({
    required String firstName,
    required String lastName,
    required String phone,
    required String password,
    required String barangay,
  }) async {
    try {
      // Validate input
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult(
          success: false,
          error: 'First name and last name are required',
        );
      }

      if (phone.trim().isEmpty || !phone.startsWith('+63')) {
        return AuthResult(
          success: false,
          error: 'Valid Philippine phone number is required',
        );
      }

      if (password.length < 6) {
        return AuthResult(
          success: false,
          error: 'Password must be at least 6 characters',
        );
      }

      // Prepare request body for truck driver creation
      final requestBody = {
        'p_first_name': firstName.trim(),
        'p_last_name': lastName.trim(),
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
          return AuthResult(
            success: true, 
            message: responseData['message'] ?? 'Truck driver account created successfully',
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to create truck driver account',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to create truck driver account: ${e.toString()}',
      );
    }
  }

  // Login user
  Future<AuthResult> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      // Validate input
      if (phone.trim().isEmpty || password.isEmpty) {
        return AuthResult(
          success: false,
          error: 'Phone number and password are required',
        );
      }

      // Prepare request body
      final requestBody = {'p_phone': phone.trim(), 'p_password': password};

      // Make HTTP request to login function
      final response = await http.post(
        Uri.parse(SupabaseConfig.loginUserEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Create User object from response
          final userData = responseData['user'];
          final user = User.fromJson(userData);

          // Store user session
          await _storeSession(user);
          _currentUser = user;

          return AuthResult(
            success: true,
            user: user,
            message: responseData['message'],
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Login failed',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(success: false, error: 'Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      _currentUser = null;
    } catch (e) {
      // Handle error silently for logout
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  // Refresh current user profile data
  Future<AuthResult> refreshCurrentUser() async {
    if (_currentUser == null) {
      return AuthResult(success: false, error: 'No user logged in');
    }

    try {
      final result = await getUserProfile(_currentUser!.id);
      if (result.success && result.user != null) {
        _currentUser = result.user;
        await _storeSession(_currentUser!);
        return AuthResult(success: true, user: _currentUser);
      }
      return result;
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to refresh user: ${e.toString()}',
      );
    }
  }

  // Get user profile by ID
  Future<AuthResult> getUserProfile(String userId) async {
    try {
      final requestBody = {'p_user_id': userId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.getUserProfileEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final userData = responseData['user'];
          final user = User.fromJson(userData);

          return AuthResult(success: true, user: user);
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get profile',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to get profile: ${e.toString()}',
      );
    }
  }

  // Store user session locally
  Future<void> _storeSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      // Note: In a real app, you'd store a proper access token here
      await prefs.setString(_tokenKey, 'user_${user.id}');
    } catch (e) {
      // Handle error silently
    }
  }

  // Restore user session from local storage
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);

      if (userJson != null && token != null) {
        final userData = jsonDecode(userJson);
        final user = User.fromJson(userData);

        // Validate that user data is complete
        if (user.id.isNotEmpty &&
            user.firstName.isNotEmpty &&
            user.lastName.isNotEmpty) {
          _currentUser = user;

          // Optionally refresh user data from server to ensure it's up to date
          // This is commented out to avoid network calls on every app start
          // You can uncomment if you want fresh data on each app launch
          // await refreshCurrentUser();
        } else {
          // User data is incomplete, clear session
          await logout();
        }
      }
    } catch (e) {
      // Handle error silently - user will need to login again
      // Clear potentially corrupted session data
      await logout();
    }
  }

  // Clear all local data
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _currentUser = null;
    } catch (e) {
      // Handle error silently
    }
  }

  // Get all truck drivers
  Future<AuthResult> getAllTruckDrivers() async {
    try {
      final response = await http.post(
        Uri.parse(SupabaseConfig.getAllTruckDriversEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return AuthResult(
            success: true,
            message: jsonEncode(responseData['drivers'] ?? []),
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get truck drivers',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to get truck drivers: ${e.toString()}',
      );
    }
  }

  // Update truck driver
  Future<AuthResult> updateTruckDriver({
    required String driverId,
    required String firstName,
    required String lastName,
    required String phone,
    required String barangay,
  }) async {
    try {
      final requestBody = {
        'p_driver_id': driverId,
        'p_first_name': firstName.trim(),
        'p_last_name': lastName.trim(),
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
          return AuthResult(
            success: true,
            message: responseData['message'] ?? 'Truck driver updated successfully',
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update truck driver',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to update truck driver: ${e.toString()}',
      );
    }
  }

  // Reset truck driver password
  Future<AuthResult> resetTruckDriverPassword({
    required String driverId,
    required String newPassword,
  }) async {
    try {
      if (newPassword.length < 6) {
        return AuthResult(
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
          return AuthResult(
            success: true,
            message: responseData['message'] ?? 'Password reset successfully',
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to reset password',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to reset password: ${e.toString()}',
      );
    }
  }

  // Delete truck driver
  Future<AuthResult> deleteTruckDriver(String driverId) async {
    try {
      final requestBody = {
        'p_driver_id': driverId,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.deleteTruckDriverEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return AuthResult(
            success: true,
            message: responseData['message'] ?? 'Truck driver deleted successfully',
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete truck driver',
          );
        }
      } else {
        return AuthResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Failed to delete truck driver: ${e.toString()}',
      );
    }
  }
}
