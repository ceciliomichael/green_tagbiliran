part of '../schedules_service.dart';

extension ScheduleQueryOperations on SchedulesService {
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

