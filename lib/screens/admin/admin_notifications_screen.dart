import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../services/notifications_service.dart';
import '../../services/auth_service.dart';
import '../../models/notification.dart';
import '../../widgets/feature/notification_stats_section.dart';
import '../../widgets/feature/notification_summary_card.dart';
import '../../widgets/feature/send_notification_dialog.dart';
import '../../widgets/feature/notification_delete_dialog.dart';
import '../../widgets/ui/notification_empty_state.dart';
import '../../widgets/ui/notification_error_state.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen> {
  final NotificationsService _notificationsService = NotificationsService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isLoadingStats = true;
  NotificationStats? _notificationStats;
  String? _statsError;

  @override
  void initState() {
    super.initState();
    _loadNotificationStats();
  }

  Future<void> _loadNotificationStats() async {
    if (_authService.currentUser == null) return;

    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });

    try {
      final result = await _notificationsService.getNotificationStats(
        adminId: _authService.currentUser!.id,
      );

      if (result.success && result.stats != null) {
        if (mounted) {
          setState(() {
            _notificationStats = result.stats;
            _isLoadingStats = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _statsError = result.error ?? 'Failed to load statistics';
            _isLoadingStats = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = 'Failed to load statistics: ${e.toString()}';
          _isLoadingStats = false;
        });
      }
    }
  }

  void _showSendNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SendNotificationDialog(
          isLoading: _isLoading,
          onSend: _sendNotification,
        );
      },
    );
  }

  Future<void> _sendNotification({
    required String title,
    required String message,
    required String targetType,
    String? targetBarangay,
  }) async {
    if (_authService.currentUser == null) {
      if (mounted) {
        _showErrorSnackBar('User not authenticated');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetTypeForApi = targetType == 'All Users' ? 'all' : 'barangay';

      final result = await _notificationsService.sendNotification(
        title: title,
        message: message,
        targetType: targetTypeForApi,
        targetBarangay: targetBarangay,
        adminId: _authService.currentUser!.id,
      );

      if (mounted) {
        if (result.success) {
          _showSuccessSnackBar(
            result.message ?? 'Notification sent successfully!',
          );
          _loadNotificationStats();
        } else {
          _showErrorSnackBar(result.error ?? 'Failed to send notification');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to send notification: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteNotificationDialog(NotificationSummary notification) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      _showErrorSnackBar('User not authenticated');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NotificationDeleteDialog(
          notification: notification,
          adminId: currentUser.id,
          onSuccess: _loadNotificationStats,
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Send notifications and announcements to users',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSendNotificationButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showSendNotificationDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 24),
            SizedBox(width: 12),
            Text(
              'Send Notification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final stats = _notificationStats!;

    return Column(
      children: [
        NotificationStatsSection(stats: stats),
        const SizedBox(height: 24),
        if (stats.recentNotifications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${stats.recentNotifications.length} sent',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...stats.recentNotifications.map(
            (notification) => NotificationSummaryCard(
              notification: notification,
              onDelete: () => _showDeleteNotificationDialog(notification),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoadingStats) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: AppColors.primaryGreen,
          ),
        ),
      );
    }

    if (_statsError != null) {
      return NotificationErrorState(
        errorMessage: _statsError,
        onRetry: _loadNotificationStats,
      );
    }

    if (_notificationStats == null ||
        _notificationStats!.totalNotifications == 0) {
      return const NotificationEmptyState();
    }

    return _buildNotificationsList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSendNotificationButton(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: _loadNotificationStats,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildContent(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

