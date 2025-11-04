import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification.dart';
import '../constants/supabase_config.dart';
import '../utils/report_status_notifier.dart';
import 'notification_overlay_service.dart';

part 'notifications/notification_result.dart';
part 'notifications/notification_admin_operations.dart';
part 'notifications/notification_user_operations.dart';
part 'notifications/notification_polling_operations.dart';

class NotificationsService {
  static final NotificationsService _instance =
      NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  // Polling management
  Timer? pollingTimer;
  bool isPolling = false;
  static const int pollingIntervalSeconds = 5; // Poll every 5 seconds (was 30)
  static const int maxPollingIntervalSeconds = 30; // Cap at 30s for exponential backoff
  static const Duration requestTimeout = Duration(seconds: 10); // Add timeout
  
  int consecutiveNoChanges = 0; // Track polls with no changes for backoff
  Future<NotificationResult>? lastFetch; // Deduplicate concurrent requests

  // Notification state
  List<NotificationModel> internalNotifications = [];
  int internalUnreadCount = 0;

  // Overlay service for banners
  final NotificationOverlayService overlayService =
      NotificationOverlayService();

  // Stream controllers for real-time updates
  final StreamController<List<NotificationModel>> notificationsController =
      StreamController<List<NotificationModel>>.broadcast();
  final StreamController<int> unreadCountController =
      StreamController<int>.broadcast();

  // Getters for current state
  List<NotificationModel> get notifications =>
      List.unmodifiable(internalNotifications);
  int get unreadCount => internalUnreadCount;

  // Streams for UI updates
  Stream<List<NotificationModel>> get notificationsStream =>
      notificationsController.stream;
  Stream<int> get unreadCountStream => unreadCountController.stream;

}
