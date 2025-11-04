import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/reports_service.dart';
import '../../services/auth_service.dart';
import '../../models/report.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/feature/admin_reports_header.dart';
import '../../widgets/feature/admin_reports_stats_row.dart';
import '../../widgets/feature/admin_reports_filter.dart';
import '../../widgets/feature/admin_reports_empty_state.dart';
import '../../widgets/feature/admin_report_card.dart';
import '../../widgets/feature/admin_report_status_update_dialog.dart';
import '../../widgets/ui/delete_confirm_dialog.dart';
import 'admin_report_detail_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _reportsService = ReportsService();
  final _authService = AuthService();

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
  ];

  List<Report> _allReports = [];
  List<Report> _filteredReports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reportsService.getAllReports(
        adminId: currentUser.id,
      );

      if (!mounted) return;

      if (result.success && result.reports != null) {
        setState(() {
          _allReports = result.reports!;
          _applyFilter();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'Failed to load reports';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'All') {
      _filteredReports = List.from(_allReports);
    } else {
      _filteredReports = _allReports
          .where((report) => report.status.matches(_selectedFilter))
          .toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilter();
    });
  }

  Future<void> _handleUpdateReport(
    Report report,
    ReportStatus newStatus,
    String? notes,
    List<XFile> images,
    String? adminName,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    String statusString = newStatus.toString().split('.').last;
    if (statusString == 'inProgress') statusString = 'in_progress';

    if (images.isNotEmpty) {
      final result = await _reportsService.updateReportStatusWithImages(
        adminId: currentUser.id,
        reportId: report.id,
        status: statusString,
        adminNotes: notes,
        images: images,
        adminName: adminName,
      );

      if (mounted) {
        _showUpdateResultSnackBar(result.success, result.error);
        if (result.success) _loadReports();
      }
    } else {
      final result = await _reportsService.updateReportStatus(
        adminId: currentUser.id,
        reportId: report.id,
        status: statusString,
        adminNotes: notes,
      );

      if (mounted) {
        _showUpdateResultSnackBar(result.success, result.error);
        if (result.success) _loadReports();
      }
    }
  }

  void _showUpdateResultSnackBar(bool success, String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Report status updated successfully'
              : error ?? 'Failed to update status',
        ),
        backgroundColor: success ? AppColors.primaryGreen : AppColors.error,
      ),
    );
  }

  void _showStatusUpdateDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AdminReportStatusUpdateDialog(
        report: report,
        onUpdate: (status, notes, images, adminName) {
          _handleUpdateReport(report, status, notes, images, adminName);
        },
      ),
    );
  }

  void _showDeleteReportDialog(Report report) {
    showDialog(
      context: context,
      builder: (dialogContext) => DeleteConfirmDialog(
        title: 'Delete Report',
        message:
            'Are you sure you want to delete this report from ${report.fullName}? This action cannot be undone.',
        onConfirm: () async {
          final currentUser = _authService.currentUser;
          if (currentUser == null) {
            if (mounted) {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User not authenticated'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }

          Navigator.pop(dialogContext);
          _showLoadingDialog();

          try {
            final result = await _reportsService.deleteReport(
              adminId: currentUser.id,
              reportId: report.id,
            );

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.success
                        ? result.message ?? 'Report deleted successfully'
                        : result.error ?? 'Failed to delete report',
                  ),
                  backgroundColor:
                      result.success ? AppColors.success : AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              if (result.success) _loadReports();
            }
          } catch (e) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  void _showReportDetails(Report report) async {
    final updatedReport = await Navigator.push<Report>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminReportDetailScreen(report: report),
      ),
    );

    if (updatedReport != null) {
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
            const AdminReportsHeader(),
            if (!_isLoading) AdminReportsStatsRow(allReports: _allReports),
            if (!_isLoading)
              AdminReportsFilter(
                selectedFilter: _selectedFilter,
                filterOptions: _filterOptions,
                onFilterChanged: _onFilterChanged,
              ),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredReports.isEmpty) {
      return const AdminReportsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _filteredReports.length,
        itemBuilder: (context, index) {
          final report = _filteredReports[index];
          return AdminReportCard(
            report: report,
            onUpdate: () => _showStatusUpdateDialog(report),
            onDetails: () => _showReportDetails(report),
            onDelete: () => _showDeleteReportDialog(report),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReports,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

