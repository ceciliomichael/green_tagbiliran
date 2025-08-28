import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/schedule.dart';
import '../constants/supabase_config.dart';

class ScheduleResult {
  final bool success;
  final String? error;
  final Schedule? schedule;
  final List<Schedule>? schedules;
  final String? message;
  final int? schedulesCreated;

  ScheduleResult({
    required this.success,
    this.error,
    this.schedule,
    this.schedules,
    this.message,
    this.schedulesCreated,
  });
}

class SchedulesService {
  static final SchedulesService _instance = SchedulesService._internal();
  factory SchedulesService() => _instance;
  SchedulesService._internal();

  // Create new schedule
  Future<ScheduleResult> createSchedule({
    required String barangay,
    required String day,
    required String time,
    required String createdBy,
  }) async {
    try {
      // Validate input
      if (barangay.trim().isEmpty || day.trim().isEmpty || time.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Barangay, day, and time are required',
        );
      }

      if (createdBy.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'User authentication required',
        );
      }

      // Prepare request body
      final requestBody = {
        'p_barangay': barangay.trim(),
        'p_day': day.trim(),
        'p_time': time.trim(),
        'p_created_by': createdBy,
      };

      // Make HTTP request to create schedule function
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/create_schedule'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final scheduleData = responseData['schedule'];
          final schedule = Schedule.fromJson(scheduleData);

          return ScheduleResult(
            success: true,
            schedule: schedule,
            message: responseData['message'] ?? 'Schedule created successfully',
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to create schedule',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to create schedule: ${e.toString()}',
      );
    }
  }

  // Get all active schedules (for users)
  Future<ScheduleResult> getAllSchedules() async {
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/get_all_schedules'),
        headers: SupabaseConfig.headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final schedulesData = responseData['schedules'] as List;
          final schedules = schedulesData
              .map((data) => Schedule.fromJson(data))
              .toList();

          return ScheduleResult(
            success: true,
            schedules: schedules,
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to fetch schedules',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to fetch schedules: ${e.toString()}',
      );
    }
  }

  // Get schedules by admin user (including inactive)
  Future<ScheduleResult> getSchedulesByAdmin(String adminId) async {
    try {
      if (adminId.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Admin ID is required',
        );
      }

      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/get_schedules_by_admin'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final schedulesData = responseData['schedules'] as List;
          final schedules = schedulesData
              .map((data) => Schedule.fromJson(data))
              .toList();

          return ScheduleResult(
            success: true,
            schedules: schedules,
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to fetch schedules',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to fetch schedules: ${e.toString()}',
      );
    }
  }

  // Update schedule
  Future<ScheduleResult> updateSchedule({
    required String scheduleId,
    required String barangay,
    required String day,
    required String time,
    required String userId,
    bool isActive = true,
  }) async {
    try {
      // Validate input
      if (barangay.trim().isEmpty || day.trim().isEmpty || time.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Barangay, day, and time are required',
        );
      }

      if (scheduleId.trim().isEmpty || userId.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Invalid schedule or user ID',
        );
      }

      // Prepare request body
      final requestBody = {
        'p_schedule_id': scheduleId,
        'p_barangay': barangay.trim(),
        'p_day': day.trim(),
        'p_time': time.trim(),
        'p_user_id': userId,
        'p_is_active': isActive,
      };

      // Make HTTP request to update schedule function
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/update_schedule'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final scheduleData = responseData['schedule'];
          final schedule = Schedule.fromJson(scheduleData);

          return ScheduleResult(
            success: true,
            schedule: schedule,
            message: responseData['message'] ?? 'Schedule updated successfully',
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update schedule',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to update schedule: ${e.toString()}',
      );
    }
  }

  // Delete schedule
  Future<ScheduleResult> deleteSchedule({
    required String scheduleId,
    required String userId,
  }) async {
    try {
      if (scheduleId.trim().isEmpty || userId.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Invalid schedule or user ID',
        );
      }

      final requestBody = {
        'p_schedule_id': scheduleId,
        'p_user_id': userId,
      };

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/delete_schedule'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return ScheduleResult(
            success: true,
            message: responseData['message'] ?? 'Schedule deleted successfully',
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete schedule',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to delete schedule: ${e.toString()}',
      );
    }
  }

  // Seed default schedules
  Future<ScheduleResult> seedDefaultSchedules({
    required String adminId,
  }) async {
    try {
      if (adminId.trim().isEmpty) {
        return ScheduleResult(
          success: false,
          error: 'Admin ID is required',
        );
      }

      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/seed_default_schedules'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return ScheduleResult(
            success: true,
            message: responseData['message'] ?? 'Default schedules seeded successfully',
            schedulesCreated: responseData['schedules_created'] as int?,
          );
        } else {
          return ScheduleResult(
            success: false,
            error: responseData['error'] ?? 'Failed to seed default schedules',
          );
        }
      } else {
        return ScheduleResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ScheduleResult(
        success: false,
        error: 'Failed to seed default schedules: ${e.toString()}',
      );
    }
  }
}
