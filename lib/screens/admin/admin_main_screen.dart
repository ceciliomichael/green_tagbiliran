import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/routes.dart';
import '../../services/reports_service.dart';
import '../../services/auth_service.dart';
import '../../models/report.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final _reportsService = ReportsService();
  final _authService = AuthService();

  int _activeReportsCount = 0;
  bool _isLoadingReports = true;
  String? _reportsError;

  @override
  void initState() {
    super.initState();
    _loadActiveReportsCount();
  }

  Future<void> _loadActiveReportsCount() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _reportsError = 'User not logged in';
        _isLoadingReports = false;
      });
      return;
    }

    setState(() {
      _isLoadingReports = true;
      _reportsError = null;
    });

    try {
      final result = await _reportsService.getAllReports(
        adminId: currentUser.id,
      );

      if (result.success && result.reports != null) {
        // Count unresolved reports (pending + in progress)
        final activeReports = result.reports!.where((report) {
          return report.status == ReportStatus.pending ||
              report.status == ReportStatus.inProgress;
        }).length;

        setState(() {
          _activeReportsCount = activeReports;
          _isLoadingReports = false;
        });
      } else {
        setState(() {
          _reportsError = result.error ?? 'Failed to load reports';
          _isLoadingReports = false;
        });
      }
    } catch (e) {
      setState(() {
        _reportsError = 'An error occurred: ${e.toString()}';
        _isLoadingReports = false;
      });
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Green Tagbilaran Management',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Tagbilaran City, Bohol - Administrative Control',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.3),
            offset: const Offset(0, 12),
            blurRadius: 32,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.2),
            offset: const Offset(0, 6),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.primaryGreen, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.report_problem_outlined,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  _isLoadingReports
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : Text(
                          _reportsError != null ? '?' : '$_activeReportsCount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _reportsError != null
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                  const Text(
                    'Active Reports',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_reportsError != null) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _loadActiveReportsCount,
                      child: const Icon(
                        Icons.refresh,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.event_outlined,
                    color: AppColors.primaryGreen,
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Active Events',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadActiveReportsCount,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildStatsRow(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Administrative Tools',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAdminCard(
                        title: 'Report Management',
                        description:
                            'View and manage user reports, mark as resolved, and respond to issues',
                        icon: Icons.report_outlined,
                        badge: _isLoadingReports || _reportsError != null
                            ? null
                            : _activeReportsCount > 0
                            ? '$_activeReportsCount'
                            : null,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            AppRoutes.adminReports,
                          );
                          // Refresh count when returning from reports screen
                          if (result == true || mounted) {
                            _loadActiveReportsCount();
                          }
                        },
                      ),
                      _buildAdminCard(
                        title: 'Event Management',
                        description:
                            'Create, edit, and manage community events and reminders',
                        icon: Icons.event_outlined,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.adminEvents);
                        },
                      ),
                      _buildAdminCard(
                        title: 'Schedule Management',
                        description:
                            'Manage garbage collection schedules for all barangays',
                        icon: Icons.schedule_outlined,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.adminSchedule);
                        },
                      ),
                      _buildAdminCard(
                        title: 'User Management',
                        description:
                            'View and manage registered users and their information',
                        icon: Icons.people_outlined,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.adminUsers);
                        },
                      ),
                      _buildAdminCard(
                        title: 'Notifications',
                        description:
                            'Send notifications and announcements to all users',
                        icon: Icons.notifications_outlined,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminNotifications,
                          );
                        },
                      ),
                      _buildAdminCard(
                        title: 'Truck Driver Management',
                        description:
                            'Create and manage truck driver accounts for each barangay',
                        icon: Icons.local_shipping_outlined,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.adminTruckDrivers,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
