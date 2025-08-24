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

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      // Handle error silently - user will need to login again
      _currentUser = null;
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
}
