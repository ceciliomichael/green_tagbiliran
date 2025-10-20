part of '../notifications_service.dart';

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

