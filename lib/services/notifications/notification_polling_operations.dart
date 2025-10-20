part of '../notifications_service.dart';

extension NotificationPollingOperations on NotificationsService {
  // Start polling for notifications
  Future<void> startPolling(String userId) async {
    if (isPolling) return;

    isPolling = true;
    consecutiveNoChanges = 0;

    // Initial fetch
    await getUserNotifications(userId: userId);

    // Start periodic polling with dynamic intervals
    pollingTimer = Timer.periodic(
      const Duration(seconds: NotificationsService.pollingIntervalSeconds),
      (timer) async {
        if (isPolling) {
          await _pollWithIntelligence(userId);
        }
      },
    );
  }

  // Smart polling logic with exponential backoff
  Future<void> _pollWithIntelligence(String userId) async {
    // Deduplicate: skip if fetch already in progress
    if (lastFetch != null) {
      try {
        // Check if previous fetch is still running
        await lastFetch!.timeout(const Duration(milliseconds: 100));
        // If we got here, previous fetch completed, so continue
      } catch (e) {
        // Still running, skip this poll
        return;
      }
    }

    lastFetch = getUserNotifications(userId: userId);
    final result = await lastFetch;

    // Null check for result (should not be null but be defensive)
    if (result == null || !result.success) {
      // On error, reset backoff
      consecutiveNoChanges = 0;
      return;
    }

    // Check if notifications changed
    final hasChanges = (result.notifications?.length ?? 0) != internalNotifications.length ||
        (result.unreadCount ?? 0) != internalUnreadCount;

    if (!hasChanges) {
      // No changes - implement exponential backoff
      consecutiveNoChanges++;
      
      // Scale: 1st poll 5s, 2nd 10s, 3rd 15s, 4th+ 30s (capped)
      final backoffSeconds = (consecutiveNoChanges * 5).clamp(
        NotificationsService.pollingIntervalSeconds,
        NotificationsService.maxPollingIntervalSeconds,
      );

      // Reset and restart timer with new interval
      if (backoffSeconds > NotificationsService.pollingIntervalSeconds) {
        pollingTimer?.cancel();
        pollingTimer = Timer.periodic(
          Duration(seconds: backoffSeconds),
          (timer) async {
            if (isPolling) {
              await _pollWithIntelligence(userId);
            }
          },
        );
      }
    } else {
      // Changes detected - reset backoff to normal interval
      consecutiveNoChanges = 0;
      pollingTimer?.cancel();
      pollingTimer = Timer.periodic(
        const Duration(seconds: NotificationsService.pollingIntervalSeconds),
        (timer) async {
          if (isPolling) {
            await _pollWithIntelligence(userId);
          }
        },
      );
    }
  }

  // Stop polling for notifications
  void stopPolling() {
    isPolling = false;
    pollingTimer?.cancel();
    pollingTimer = null;
  }

  // Check for new notifications and show banners
  void checkForNewNotifications(List<NotificationModel> newNotifications) {
    if (internalNotifications.isEmpty) {
      // First time loading, don't show banners for existing notifications
      return;
    }

    // Find notifications that weren't in the previous list
    final existingIds = internalNotifications.map((n) => n.id).toSet();
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
      overlayService.showNotificationBanner(genuinelyNewNotifications.first);
    }
  }

  // Update notification read status locally
  void updateNotificationReadStatus(String notificationId, bool isRead) {
    internalNotifications = internalNotifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(
          isRead: isRead,
          readAt: isRead ? DateTime.now() : null,
        );
      }
      return notification;
    }).toList();

    // Recalculate unread count
    internalUnreadCount = internalNotifications.where((n) => !n.isRead).length;

    // Notify listeners
    notificationsController.add(internalNotifications);
    unreadCountController.add(internalUnreadCount);
  }

  // Clear all local data
  void clearLocalData() {
    stopPolling();
    internalNotifications.clear();
    internalUnreadCount = 0;
    notificationsController.add(internalNotifications);
    unreadCountController.add(internalUnreadCount);
  }

  // Dispose resources
  void dispose() {
    stopPolling();
    notificationsController.close();
    unreadCountController.close();
  }
}

