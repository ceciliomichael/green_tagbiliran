import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';
import '../../services/auth_service.dart';
import '../../services/notifications_service.dart';
import '../../widgets/ui/report_info_card.dart';
import '../../widgets/ui/report_status_badge.dart';
import '../../widgets/ui/image_viewer_dialog.dart';
import '../../widgets/feature/report_images_section.dart';
import '../../widgets/feature/admin_response_images_section.dart';
import '../../widgets/feature/admin_report_status_dialog.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final Report report;

  const AdminReportDetailScreen({super.key, required this.report});

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  final _reportsService = ReportsService();
  final _authService = AuthService();
  final _notificationsService = NotificationsService();

  late Report _currentReport;
  List<ReportImage> _images = [];
  List<AdminResponseImage> _adminResponseImages = [];
  bool _isLoadingImages = false;
  bool _isLoadingAdminImages = false;
  bool _isUpdatingStatus = false;
  String? _imageError;
  String? _adminImageError;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
    if (_currentReport.hasImage) {
      _loadReportImages();
    }
    if (_currentReport.hasAdminResponseImage) {
      _loadAdminResponseImages();
    }
  }

  Future<void> _loadReportImages() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingImages = true;
      _imageError = null;
    });

    try {
      final result = await _reportsService.getReportImages(
        userId: currentUser.id,
        reportId: _currentReport.id,
      );

      if (!mounted) return;

      if (result.success && result.images != null) {
        setState(() {
          _images = result.images!;
          _isLoadingImages = false;
        });
      } else {
        setState(() {
          _imageError = result.error ?? 'Failed to load images';
          _isLoadingImages = false;
        });
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      setState(() {
        _imageError =
            'Error loading images: ${e.toString()}\nStack: ${stackTrace.toString().split('\n').take(3).join('\n')}';
        _isLoadingImages = false;
      });
      debugPrint('Image loading error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadAdminResponseImages() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingAdminImages = true;
      _adminImageError = null;
    });

    try {
      final result = await _reportsService.getAdminResponseImages(
        userId: currentUser.id,
        reportId: _currentReport.id,
      );

      if (!mounted) return;

      if (result.success && result.adminResponseImages != null) {
        setState(() {
          _adminResponseImages = result.adminResponseImages!;
          _isLoadingAdminImages = false;
        });
      } else {
        setState(() {
          _adminImageError =
              result.error ?? 'Failed to load admin response images';
          _isLoadingAdminImages = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _adminImageError =
            'Failed to load admin response images: ${e.toString()}';
        _isLoadingAdminImages = false;
      });
    }
  }

  Future<void> _updateReportStatus(
    ReportStatus newStatus,
    String? notes,
    List<XFile>? responseImages,
    String? adminName,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    if (!mounted) return;
    setState(() {
      _isUpdatingStatus = true;
    });

    String statusString = newStatus.toString().split('.').last;
    if (statusString == 'inProgress') statusString = 'in_progress';

    final result = await _reportsService.updateReportStatusWithImages(
      adminId: currentUser.id,
      reportId: _currentReport.id,
      status: statusString,
      adminNotes: notes,
      images: responseImages,
      adminName: adminName,
    );

    if (!mounted) return;

    if (result.success) {
      // Send notification to user if status is resolved or rejected
      if (statusString == 'resolved' || statusString == 'rejected') {
        await _notificationsService.sendReportStatusNotification(
          userId: _currentReport.userId,
          reportId: _currentReport.id,
          status: statusString,
          adminId: currentUser.id,
          adminNotes: notes,
        );
      }

      if (!mounted) return;

      setState(() {
        _currentReport = _currentReport.copyWith(
          status: newStatus,
          adminNotes: notes,
          updatedAt: DateTime.now(),
          hasAdminResponseImage:
              responseImages != null && responseImages.isNotEmpty ||
              _currentReport.hasAdminResponseImage,
        );
        _isUpdatingStatus = false;
      });

      // Reload admin response images if they were uploaded
      if (responseImages != null && responseImages.isNotEmpty) {
        _loadAdminResponseImages();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report status updated successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } else {
      setState(() {
        _isUpdatingStatus = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update status'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AdminReportStatusDialog(
          currentReport: _currentReport,
          adminResponseImages: _adminResponseImages,
          onUpdateStatus: _updateReportStatus,
          isUpdating: _isUpdatingStatus,
        );
      },
    );
  }

  void _showImageDialog(ReportImage image) {
    showDialog(
      context: context,
      builder: (context) => ImageViewerDialog.fromReportImage(image),
    );
  }





  void _showAdminImageDialog(AdminResponseImage image) {
    showDialog(
      context: context,
      builder: (context) => ImageViewerDialog.fromAdminResponseImage(image),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: Text(
          'Report #${_currentReport.id.substring(0, 8)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _currentReport),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showStatusUpdateDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                ReportStatusBadge(status: _currentReport.status),
              ],
            ),
            const SizedBox(height: 24),

            // User Information
            ReportInfoCard(
              title: 'Reporter Name',
              value: _currentReport.fullName,
              icon: Icons.person_outline,
            ),

            ReportInfoCard(
              title: 'Phone Number',
              value: _currentReport.phone,
              icon: Icons.phone_outlined,
            ),

            ReportInfoCard(
              title: 'Location',
              value: '${_currentReport.barangay} Barangay',
              icon: Icons.location_on_outlined,
            ),

            ReportInfoCard(
              title: 'Submitted',
              value: _formatDateTime(_currentReport.createdAt),
              icon: Icons.access_time,
            ),

            ReportInfoCard(
              title: 'Last Updated',
              value: _formatDateTime(_currentReport.updatedAt),
              icon: Icons.update,
            ),

            // Issue Description
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Issue Description',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentReport.issueDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Images Section
            ReportImagesSection(
              report: _currentReport,
              images: _images,
              isLoading: _isLoadingImages,
              error: _imageError,
              onImageTap: _showImageDialog,
            ),

            // Admin Response Images Section
            AdminResponseImagesSection(
              report: _currentReport,
              adminResponseImages: _adminResponseImages,
              isLoading: _isLoadingAdminImages,
              error: _adminImageError,
              onImageTap: _showAdminImageDialog,
            ),

            // Admin Notes
            if (_currentReport.adminNotes != null &&
                _currentReport.adminNotes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: AppColors.primaryGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Admin Notes',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentReport.adminNotes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _showStatusUpdateDialog,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(
                          color: AppColors.primaryGreen,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                      // Show contact user dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: AppColors.pureWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Contact User',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'You can contact the user through:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone: ${_currentReport.phone}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Name: ${_currentReport.fullName}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                      icon: const Icon(
                        Icons.phone_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Contact',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
