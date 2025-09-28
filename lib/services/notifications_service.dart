import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../constants/supabase_config.dart';
import 'notification_overlay_service.dart';

class NotificationResult {
  final bool success;
  final String? error;
  final String? message;
  final List<NotificationModel>? notifications;
  final int? unreadCount;
  final NotificationStats? stats;

  NotificationResult({
    required this.success,
    this.error,
    this.message,
    this.notifications,
    this.unreadCount,
    this.stats,
  });
}

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  // Polling management
  Timer? _pollingTimer;
  bool _isPolling = false;
  static const int _pollingIntervalSeconds = 30; // Poll every 30 seconds

  // Notification state
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  // Overlay service for banners
  final NotificationOverlayService _overlayService =
      NotificationOverlayService();

  // Stream controllers for real-time updates
  final StreamController<List<NotificationModel>> _notificationsController =
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  // Getters for current state
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  // Streams for UI updates
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

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
          _checkForNewNotifications(notifications);

          // Update internal state
          _notifications = notifications;
          _unreadCount = unreadCount;

          // Notify listeners
          _notificationsController.add(_notifications);
          _unreadCountController.add(_unreadCount);

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
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local state
          _updateNotificationReadStatus(notificationId, true);

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
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local state - mark all notifications as read
          _notifications = _notifications.map((notification) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }).toList();

          _unreadCount = 0;

          // Notify listeners
          _notificationsController.add(_notifications);
          _unreadCountController.add(_unreadCount);

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

  // Start polling for notifications
  Future<void> startPolling(String userId) async {
    if (_isPolling) return;

    _isPolling = true;

    // Initial fetch
    await getUserNotifications(userId: userId);

    // Start periodic polling
    _pollingTimer = Timer.periodic(
      const Duration(seconds: _pollingIntervalSeconds),
      (timer) async {
        if (_isPolling) {
          await getUserNotifications(userId: userId);
        }
      },
    );
  }

  // Stop polling for notifications
  void stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Check for new notifications and show banners
  void _checkForNewNotifications(List<NotificationModel> newNotifications) {
    if (_notifications.isEmpty) {
      // First time loading, don't show banners for existing notifications
      return;
    }

    // Find notifications that weren't in the previous list
    final existingIds = _notifications.map((n) => n.id).toSet();
    final genuinelyNewNotifications = newNotifications
        .where(
          (notification) =>
              !existingIds.contains(notification.id) && !notification.isRead,
        )
        .toList();

    // Show banner for the most recent new notification
    if (genuinelyNewNotifications.isNotEmpty) {
      // Sort by creation date and show the most recent one
      genuinelyNewNotifications.sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
      _overlayService.showNotificationBanner(genuinelyNewNotifications.first);
    }
  }

  // Update notification read status locally
  void _updateNotificationReadStatus(String notificationId, bool isRead) {
    _notifications = _notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(
          isRead: isRead,
          readAt: isRead ? DateTime.now() : null,
        );
      }
      return notification;
    }).toList();

    // Recalculate unread count
    _unreadCount = _notifications.where((n) => !n.isRead).length;

    // Notify listeners
    _notificationsController.add(_notifications);
    _unreadCountController.add(_unreadCount);
  }

  // Clear all local data
  void clearLocalData() {
    stopPolling();
    _notifications.clear();
    _unreadCount = 0;
    _notificationsController.add(_notifications);
    _unreadCountController.add(_unreadCount);
  }

  // Dispose resources
  void dispose() {
    stopPolling();
    _notificationsController.close();
    _unreadCountController.close();
  }
}
