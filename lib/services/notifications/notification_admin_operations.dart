part of '../notifications_service.dart';

extension NotificationAdminOperations on NotificationsService {
  // Send notification (admin only)
  Future<NotificationResult> sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetBarangay,
    required String adminId,
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty || message.trim().isEmpty) {
        return NotificationResult(
          success: false,
          error: 'Title and message are required',
        );
      }

      if (!['all', 'barangay'].contains(targetType)) {
        return NotificationResult(
          success: false,
          error: 'Target type must be "all" or "barangay"',
        );
      }

      if (targetType == 'barangay' &&
          (targetBarangay == null || targetBarangay.trim().isEmpty)) {
        return NotificationResult(
          success: false,
          error: 'Target barangay is required when target type is "barangay"',
        );
      }

      // Prepare request body
      final requestBody = {
        'p_title': title.trim(),
        'p_message': message.trim(),
        'p_target_type': targetType,
        'p_created_by': adminId,
        'p_target_barangay': targetType == 'barangay'
            ? targetBarangay!.trim()
            : null,
      };

      // Make HTTP request
      final response = await http.post(
        Uri.parse(SupabaseConfig.sendNotificationEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Send notification timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return NotificationResult(
            success: true,
            message:
                responseData['message'] ?? 'Notification sent successfully',
          );
        } else {
          return NotificationResult(
            success: false,
            error: responseData['error'] ?? 'Failed to send notification',
          );
        }
      } else {
        return NotificationResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        error: 'Failed to send notification: ${e.toString()}',
      );
    }
  }

  // Get notification statistics (admin only)
  Future<NotificationResult> getNotificationStats({
    required String adminId,
  }) async {
    try {
      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.getNotificationStatsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Get notification stats timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final stats = NotificationStats.fromJson(responseData);

          return NotificationResult(success: true, stats: stats);
        } else {
          return NotificationResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get notification stats',
          );
        }
      } else {
        return NotificationResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        error: 'Failed to get notification stats: ${e.toString()}',
      );
    }
  }

  // Delete notification (admin only)
  Future<NotificationResult> deleteNotification({
    required String notificationId,
    required String adminId,
  }) async {
    try {
      final requestBody = {
        'p_notification_id': notificationId,
        'p_admin_id': adminId,
      };

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/delete_notification'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Delete notification timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return NotificationResult(
            success: true,
            message:
                responseData['message'] ?? 'Notification deleted successfully',
          );
        } else {
          return NotificationResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete notification',
          );
        }
      } else {
        return NotificationResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        error: 'Failed to delete notification: ${e.toString()}',
      );
    }
  }

  // Send notification to specific user about their report status (admin only)
  Future<NotificationResult> sendReportStatusNotification({
    required String userId,
    required String reportId,
    required String status,
    required String adminId,
    String? adminNotes,
  }) async {
    try {
      // Get notification content using utility
      final content =
          ReportStatusNotifier.getNotificationContent(status, adminNotes);
      final title = content['title']!;
      final message = content['message']!;

      // Prepare request body for individual user notification
      final requestBody = {
        'p_title': title,
        'p_message': message,
        'p_target_type': 'user',
        'p_created_by': adminId,
        'p_target_user_id': userId,
      };

      // Make HTTP request
      final response = await http.post(
        Uri.parse(SupabaseConfig.sendNotificationEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Send report notification timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return NotificationResult(
            success: true,
            message: responseData['message'] ?? 'Notification sent successfully',
          );
        } else {
          return NotificationResult(
            success: false,
            error: responseData['error'] ?? 'Failed to send notification',
          );
        }
      } else {
        return NotificationResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return NotificationResult(
        success: false,
        error: 'Failed to send report notification: ${e.toString()}',
      );
    }
  }
}

