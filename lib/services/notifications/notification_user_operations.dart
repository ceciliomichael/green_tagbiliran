part of '../notifications_service.dart';

extension NotificationUserOperations on NotificationsService {
  // Get user notifications
  Future<NotificationResult> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final requestBody = {
        'p_user_id': userId,
        'p_limit': limit,
        'p_offset': offset,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.getUserNotificationsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Notifications fetch timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final notificationsList =
              responseData['notifications'] as List<dynamic>? ?? [];
          final notifications = notificationsList
              .map(
                (item) =>
                    NotificationModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          final unreadCount = responseData['unread_count'] as int? ?? 0;

          // Check for new notifications to show banners
          checkForNewNotifications(notifications);

          // Update internal state
          internalNotifications = notifications;
          internalUnreadCount = unreadCount;

          // Notify listeners
          notificationsController.add(internalNotifications);
          unreadCountController.add(internalUnreadCount);

          return NotificationResult(
            success: true,
            notifications: notifications,
            unreadCount: unreadCount,
          );
        } else {
          return NotificationResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get notifications',
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
        error: 'Failed to get notifications: ${e.toString()}',
      );
    }
  }

  // Mark notification as read
  Future<NotificationResult> markNotificationRead({
    required String notificationId,
    required String userId,
  }) async {
    try {
      final requestBody = {
        'p_notification_id': notificationId,
        'p_user_id': userId,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.markNotificationReadEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Mark notification read timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local state
          updateNotificationReadStatus(notificationId, true);

          return NotificationResult(
            success: true,
            message: responseData['message'] ?? 'Notification marked as read',
          );
        } else {
          return NotificationResult(
            success: false,
            error:
                responseData['error'] ?? 'Failed to mark notification as read',
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
        error: 'Failed to mark notification as read: ${e.toString()}',
      );
    }
  }

  // Mark all notifications as read
  Future<NotificationResult> markAllNotificationsRead({
    required String userId,
  }) async {
    try {
      final requestBody = {'p_user_id': userId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.markAllNotificationsReadEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      ).timeout(
        NotificationsService.requestTimeout,
        onTimeout: () => throw TimeoutException(
          'Mark all notifications read timed out',
          NotificationsService.requestTimeout,
        ),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local state - mark all notifications as read
          internalNotifications = internalNotifications.map((notification) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }).toList();

          internalUnreadCount = 0;

          // Notify listeners
          notificationsController.add(internalNotifications);
          unreadCountController.add(internalUnreadCount);

          return NotificationResult(
            success: true,
            message:
                responseData['message'] ?? 'All notifications marked as read',
          );
        } else {
          return NotificationResult(
            success: false,
            error:
                responseData['error'] ??
                'Failed to mark all notifications as read',
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
        error: 'Failed to mark all notifications as read: ${e.toString()}',
      );
    }
  }
}

