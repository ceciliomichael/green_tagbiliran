import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../constants/supabase_config.dart';
import '../utils/session_manager.dart';
import 'notifications_service.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? message;

  AuthResult({required this.success, this.error, this.user, this.message});
}

/// Service for user authentication and profile management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Current user state
  User? _currentUser;
  User? get currentUser => _currentUser;

  /// Initialize auth service and restore session
  Future<void> initialize() async {
    await _restoreSession();
  }

  /// Register a new user
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

  /// Login user
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
          await SessionManager.storeSession(user);
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

  /// Logout user
  Future<void> logout() async {
    try {
      await SessionManager.clearSession();
      _currentUser = null;

      // Clear notification data
      final notificationsService = NotificationsService();
      notificationsService.clearLocalData();
    } catch (e) {
      // Handle error silently for logout
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Refresh current user profile data
  Future<AuthResult> refreshCurrentUser() async {
    if (_currentUser == null) {
      return AuthResult(success: false, error: 'No user logged in');
    }

    try {
      final result = await getUserProfile(_currentUser!.id);
      if (result.success && result.user != null) {
        _currentUser = result.user;
        await SessionManager.storeSession(_currentUser!);
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

  /// Get user profile by ID
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

  /// Update user profile
  Future<AuthResult> updateUserProfile({
    required String firstName,
    required String lastName,
    required String barangay,
    String? phone,
  }) async {
    if (_currentUser == null) {
      return AuthResult(success: false, error: 'No user logged in');
    }

    try {
      // Validate input
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult(
          success: false,
          error: 'First name and last name are required',
        );
      }

      // Prepare request body
      final requestBody = {
        'p_user_id': _currentUser!.id,
        'p_first_name': firstName.trim(),
        'p_last_name': lastName.trim(),
        'p_barangay': barangay,
        if (phone != null) 'p_phone': phone.trim(),
      };

      // Make HTTP request to update profile function
      final response = await http.post(
        Uri.parse(SupabaseConfig.updateUserProfileEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local user data
          final userData = responseData['user'];
          final updatedUser = User.fromJson(userData);

          _currentUser = updatedUser;
          await SessionManager.storeSession(_currentUser!);

          return AuthResult(
            success: true,
            user: updatedUser,
            message: responseData['message'] ?? 'Profile updated successfully',
          );
        } else {
          return AuthResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update profile',
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
        error: 'Failed to update profile: ${e.toString()}',
      );
    }
  }

  /// Restore user session from local storage
  Future<void> _restoreSession() async {
    try {
      final user = await SessionManager.restoreSession();
      
      if (user != null) {
        _currentUser = user;
        
        // Optionally refresh user data from server to ensure it's up to date
        // This is commented out to avoid network calls on every app start
        // You can uncomment if you want fresh data on each app launch
        // await refreshCurrentUser();
      } else {
        // Session restoration failed, clear any corrupted data
        await logout();
      }
    } catch (e) {
      // Handle error silently - user will need to login again
      // Clear potentially corrupted session data
      await logout();
    }
  }

  /// Clear all local data
  Future<void> clearLocalData() async {
    try {
      await SessionManager.clearAllData();
      _currentUser = null;
    } catch (e) {
      // Handle error silently
    }
  }
}
