import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/reports_service.dart';
import '../../services/auth_service.dart';
import '../../models/report.dart';
import '../../widgets/common/loading_indicator.dart';
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
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reportsService.getAllReports(
        adminId: currentUser.id,
      );

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
      String statusFilter = _selectedFilter.toLowerCase().replaceAll(' ', '_');
      _filteredReports = _allReports.where((report) {
        switch (statusFilter) {
          case 'pending':
            return report.status == ReportStatus.pending;
          case 'in_progress':
            return report.status == ReportStatus.inProgress;
          case 'resolved':
            return report.status == ReportStatus.resolved;
          default:
            return true;
        }
      }).toList();
    }
  }

  int _getStatusCount(ReportStatus status) {
    return _allReports.where((report) => report.status == status).length;
  }

  Future<void> _updateReportStatus(
    Report report,
    ReportStatus newStatus,
    String? notes,
  ) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    String statusString = newStatus.toString().split('.').last;
    if (statusString == 'inProgress') statusString = 'in_progress';

    final result = await _reportsService.updateReportStatus(
      adminId: currentUser.id,
      reportId: report.id,
      status: statusString,
      adminNotes: notes,
    );

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report status updated successfully'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
      _loadReports(); // Reload reports
    } else {
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
                  'Report Management',
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
            'View and manage user-submitted reports',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final option = _filterOptions[index];
          final isSelected = option == _selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = option;
                  _applyFilter();
                });
              },
              backgroundColor: Colors.transparent,
              selectedColor: AppColors.primaryGreen,
              side: BorderSide(color: AppColors.primaryGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Reports Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'User-submitted reports will appear here. When users report issues through the app, you can view and manage them from this screen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reports will be automatically sorted by status',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    '${_getStatusCount(ReportStatus.pending)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    '${_getStatusCount(ReportStatus.inProgress)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'In Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
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
                  Text(
                    '${_getStatusCount(ReportStatus.resolved)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Resolved',
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

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.phone,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(report.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              report.issueDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  report.barangay,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(report.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (report.hasImage) ...[
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.image_outlined,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ],
            ),
            if (report.adminNotes != null && report.adminNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Notes:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.adminNotes!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showStatusUpdateDialog(report),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Update Status',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showReportDetails(report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case ReportStatus.pending:
        backgroundColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        text = 'Pending';
        break;
      case ReportStatus.inProgress:
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        text = 'In Progress';
        break;
      case ReportStatus.resolved:
        backgroundColor = AppColors.primaryGreen.withValues(alpha: 0.1);
        textColor = AppColors.primaryGreen;
        text = 'Resolved';
        break;
      case ReportStatus.rejected:
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        text = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStatusUpdateDialog(Report report) {
    // Set initial status to current report status
    String? selectedStatus = report.status.toString().split('.').last;
    if (selectedStatus == 'inProgress') selectedStatus = 'in_progress';

    final notesController = TextEditingController(
      text: report.adminNotes ?? '',
    );
    final adminNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<XFile> selectedImages = [];
    final imagePicker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Update Report Status',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 650,
                  ),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Report Status',
                              hintText: 'Select new status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Text('Pending'),
                              ),
                              DropdownMenuItem(
                                value: 'in_progress',
                                child: Text('In Progress'),
                              ),
                              DropdownMenuItem(
                                value: 'resolved',
                                child: Text('Resolved'),
                              ),
                              DropdownMenuItem(
                                value: 'rejected',
                                child: Text('Rejected'),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setDialogState(() {
                                  selectedStatus = newValue;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a status';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: notesController,
                            decoration: InputDecoration(
                              labelText: 'Admin Notes',
                              hintText: 'Add notes for the user...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                            ),
                            maxLines: 4,
                            maxLength: 500,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: adminNameController,
                            decoration: InputDecoration(
                              labelText: 'Your Name (Optional)',
                              hintText:
                                  'Enter your name so the user knows who resolved their issue...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            maxLength: 100,
                            validator: (value) {
                              if (value != null &&
                                  value.trim().isNotEmpty &&
                                  value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.attach_file,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Attach Response Images (Optional)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Add up to 3 images to show the user how the issue was resolved',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (selectedImages.isEmpty)
                                  GestureDetector(
                                    onTap: () async {
                                      try {
                                        final images = await imagePicker
                                            .pickMultiImage(imageQuality: 70);
                                        if (images.isNotEmpty) {
                                          // Limit to 3 images
                                          final limitedImages = images
                                              .take(3)
                                              .toList();
                                          setDialogState(() {
                                            selectedImages = limitedImages;
                                          });
                                        }
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to select images: ${e.toString()}',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 80,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryGreen
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primaryGreen
                                              .withValues(alpha: 0.3),
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: AppColors.primaryGreen,
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Tap to select images',
                                            style: TextStyle(
                                              color: AppColors.primaryGreen,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: selectedImages.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: EdgeInsets.only(
                                                right:
                                                    index <
                                                        selectedImages.length -
                                                            1
                                                    ? 8
                                                    : 0,
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: AppColors
                                                            .primaryGreen
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            7,
                                                          ),
                                                      child: FutureBuilder<Uint8List>(
                                                        future:
                                                            selectedImages[index]
                                                                .readAsBytes(),
                                                        builder: (context, snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            return Image.memory(
                                                              snapshot.data!,
                                                              fit: BoxFit.cover,
                                                            );
                                                          }
                                                          return const Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setDialogState(() {
                                                          selectedImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppColors
                                                                  .error,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (selectedImages.length < 3)
                                        GestureDetector(
                                          onTap: () async {
                                            try {
                                              final remainingSlots =
                                                  3 - selectedImages.length;
                                              final images = await imagePicker
                                                  .pickMultiImage(
                                                    imageQuality: 70,
                                                  );
                                              if (images.isNotEmpty) {
                                                final limitedImages = images
                                                    .take(remainingSlots)
                                                    .toList();
                                                setDialogState(() {
                                                  selectedImages.addAll(
                                                    limitedImages,
                                                  );
                                                });
                                              }
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to select images: ${e.toString()}',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.error,
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                              horizontal: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGreen
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: AppColors.primaryGreen
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.add,
                                                  color: AppColors.primaryGreen,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Add more (${selectedImages.length}/3)',
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.primaryGreen,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      ReportStatus newStatus;
                      switch (selectedStatus) {
                        case 'pending':
                          newStatus = ReportStatus.pending;
                          break;
                        case 'in_progress':
                          newStatus = ReportStatus.inProgress;
                          break;
                        case 'resolved':
                          newStatus = ReportStatus.resolved;
                          break;
                        case 'rejected':
                          newStatus = ReportStatus.rejected;
                          break;
                        default:
                          return;
                      }
                      Navigator.pop(context);
                      final currentUser = _authService.currentUser;
                      if (currentUser != null && selectedImages.isNotEmpty) {
                        final statusString =
                            newStatus == ReportStatus.inProgress
                            ? 'in_progress'
                            : newStatus.toString().split('.').last;
                        await _reportsService.updateReportStatusWithImages(
                          adminId: currentUser.id,
                          reportId: report.id,
                          status: statusString,
                          adminNotes: notesController.text.trim(),
                          images: selectedImages,
                          adminName: adminNameController.text.trim().isNotEmpty
                              ? adminNameController.text.trim()
                              : null,
                        );
                        _loadReports();
                      } else {
                        _updateReportStatus(
                          report,
                          newStatus,
                          notesController.text.trim(),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showReportDetails(Report report) async {
    final updatedReport = await Navigator.push<Report>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminReportDetailScreen(report: report),
      ),
    );

    // If the report was updated in the detail screen, refresh the list
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
            _buildHeader(),
            if (!_isLoading) _buildStatsRow(),
            if (!_isLoading) _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: LoadingIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Reports',
                            style: const TextStyle(
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
                    )
                  : _filteredReports.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadReports,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: _filteredReports.length,
                        itemBuilder: (context, index) {
                          return _buildReportCard(_filteredReports[index]);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
