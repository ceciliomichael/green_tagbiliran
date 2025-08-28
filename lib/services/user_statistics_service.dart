import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/supabase_config.dart';

class UserStatistics {
  final int totalUsers;
  final int newUsersThisWeek;
  final int activeUsers;
  final int totalReports;

  UserStatistics({
    required this.totalUsers,
    required this.newUsersThisWeek,
    required this.activeUsers,
    required this.totalReports,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['total_users'] as int? ?? 0,
      newUsersThisWeek: json['new_users_week'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalReports: json['total_reports'] as int? ?? 0,
    );
  }
}

class UserRegistrationTrend {
  final DateTime weekStart;
  final int registrations;

  UserRegistrationTrend({
    required this.weekStart,
    required this.registrations,
  });

  factory UserRegistrationTrend.fromJson(Map<String, dynamic> json) {
    return UserRegistrationTrend(
      weekStart: DateTime.parse(json['week_start'] as String),
      registrations: json['registrations'] as int? ?? 0,
    );
  }
}

class BarangayActivity {
  final String barangay;
  final int totalUsers;
  final int activeUsers;
  final int totalReports;

  BarangayActivity({
    required this.barangay,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalReports,
  });

  factory BarangayActivity.fromJson(Map<String, dynamic> json) {
    return BarangayActivity(
      barangay: json['barangay'] as String? ?? '',
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalReports: json['total_reports'] as int? ?? 0,
    );
  }
}

class UserStatisticsResult {
  final bool success;
  final String? error;
  final UserStatistics? statistics;
  final List<UserRegistrationTrend>? trends;
  final List<BarangayActivity>? barangayActivity;
  final String? message;

  UserStatisticsResult({
    required this.success,
    this.error,
    this.statistics,
    this.trends,
    this.barangayActivity,
    this.message,
  });
}

class UserStatisticsService {
  static final UserStatisticsService _instance = UserStatisticsService._internal();
  factory UserStatisticsService() => _instance;
  UserStatisticsService._internal();

  // API endpoints
  static const String _getUserStatisticsEndpoint = '${SupabaseConfig.baseApiUrl}/get_user_statistics';
  static const String _getUserRegistrationTrendsEndpoint = '${SupabaseConfig.baseApiUrl}/get_user_registration_trends';
  static const String _getUserActivityByBarangayEndpoint = '${SupabaseConfig.baseApiUrl}/get_user_activity_by_barangay';

  // Get comprehensive user statistics
  Future<UserStatisticsResult> getUserStatistics(String adminId) async {
    try {
      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse(_getUserStatisticsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final statisticsData = responseData['statistics'] as Map<String, dynamic>;
          final statistics = UserStatistics.fromJson(statisticsData);

          return UserStatisticsResult(
            success: true,
            statistics: statistics,
          );
        } else {
          return UserStatisticsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get user statistics',
          );
        }
      } else {
        return UserStatisticsResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return UserStatisticsResult(
        success: false,
        error: 'Failed to get user statistics: ${e.toString()}',
      );
    }
  }

  // Get user registration trends
  Future<UserStatisticsResult> getUserRegistrationTrends(
    String adminId, {
    int weeks = 12,
  }) async {
    try {
      final requestBody = {
        'p_admin_id': adminId,
        'p_weeks': weeks,
      };

      final response = await http.post(
        Uri.parse(_getUserRegistrationTrendsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final trendsJson = responseData['trends'] as List<dynamic>? ?? [];
          final trends = trendsJson
              .map((json) => UserRegistrationTrend.fromJson(json as Map<String, dynamic>))
              .toList();

          return UserStatisticsResult(
            success: true,
            trends: trends,
          );
        } else {
          return UserStatisticsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get registration trends',
          );
        }
      } else {
        return UserStatisticsResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return UserStatisticsResult(
        success: false,
        error: 'Failed to get registration trends: ${e.toString()}',
      );
    }
  }

  // Get user activity by barangay
  Future<UserStatisticsResult> getUserActivityByBarangay(String adminId) async {
    try {
      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse(_getUserActivityByBarangayEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final activityJson = responseData['activity'] as List<dynamic>? ?? [];
          final barangayActivity = activityJson
              .map((json) => BarangayActivity.fromJson(json as Map<String, dynamic>))
              .toList();

          return UserStatisticsResult(
            success: true,
            barangayActivity: barangayActivity,
          );
        } else {
          return UserStatisticsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get barangay activity',
          );
        }
      } else {
        return UserStatisticsResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return UserStatisticsResult(
        success: false,
        error: 'Failed to get barangay activity: ${e.toString()}',
      );
    }
  }

  // Format number with commas for display
  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // Calculate percentage change between two numbers
  double calculatePercentageChange(int current, int previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  // Get activity status based on number of active users vs total users
  String getActivityStatus(int activeUsers, int totalUsers) {
    if (totalUsers == 0) return 'No Users';
    
    final percentage = (activeUsers / totalUsers) * 100;
    
    if (percentage >= 70) return 'Excellent';
    if (percentage >= 50) return 'Good';
    if (percentage >= 30) return 'Fair';
    return 'Low';
  }
}
