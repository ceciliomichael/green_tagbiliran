import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Manages user session storage and retrieval
class SessionManager {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'access_token';

  /// Store user session locally
  static Future<void> storeSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      // Note: In a real app, you'd store a proper access token here
      await prefs.setString(_tokenKey, 'user_${user.id}');
    } catch (e) {
      // Handle error silently
    }
  }

  /// Restore user session from local storage
  static Future<User?> restoreSession() async {
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
          return user;
        }
      }
      return null;
    } catch (e) {
      // Return null if session restoration fails
      return null;
    }
  }

  /// Clear user session
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear all local data
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Check if session exists
  static Future<bool> hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey) && prefs.containsKey(_tokenKey);
    } catch (e) {
      return false;
    }
  }
}








