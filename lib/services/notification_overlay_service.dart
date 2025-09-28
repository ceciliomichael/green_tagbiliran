import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../widgets/common/notification_banner.dart';
import '../constants/routes.dart';

class NotificationOverlayService {
  static final NotificationOverlayService _instance =
      NotificationOverlayService._internal();
  factory NotificationOverlayService() => _instance;
  NotificationOverlayService._internal();

  OverlayEntry? _currentOverlay;
  BuildContext? _context;

  // Set the context for the overlay (usually from the main app)
  void setContext(BuildContext context) {
    _context = context;
  }

  // Show a notification banner
  void showNotificationBanner(NotificationModel notification) {
    if (_context == null) return;

    // Remove any existing banner first
    hideNotificationBanner();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: NotificationBanner(
          notification: notification,
          onTap: () {
            hideNotificationBanner();
            _navigateToNotifications();
          },
          onDismiss: hideNotificationBanner,
        ),
      ),
    );

    Overlay.of(_context!).insert(_currentOverlay!);
  }

  // Hide the current notification banner
  void hideNotificationBanner() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  // Navigate to notifications screen
  void _navigateToNotifications() {
    if (_context != null) {
      Navigator.pushNamed(_context!, AppRoutes.notifications);
    }
  }

  // Clear context when app is disposed
  void dispose() {
    hideNotificationBanner();
    _context = null;
  }
}
