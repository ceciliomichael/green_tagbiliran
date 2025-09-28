import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/loading_indicator.dart';

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

    setState(() {
      _isUpdatingStatus = false;
    });

    if (result.success) {
      setState(() {
        _currentReport = _currentReport.copyWith(
          status: newStatus,
          adminNotes: notes,
          updatedAt: DateTime.now(),
          hasAdminResponseImage:
              responseImages != null && responseImages.isNotEmpty ||
              _currentReport.hasAdminResponseImage,
        );
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
    // Set initial status to current report status
    String? selectedStatus = _currentReport.status.toString().split('.').last;
    if (selectedStatus == 'inProgress') selectedStatus = 'in_progress';

    final notesController = TextEditingController(
      text: _currentReport.adminNotes ?? '',
    );
    final adminNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    List<XFile> selectedImages = [];
    final imagePicker = ImagePicker();

    // Show current count of existing admin response images
    final int existingImageCount = _adminResponseImages.length;

    final List<Map<String, String>> statusOptions = [
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'resolved', 'label': 'Resolved'},
      {'value': 'rejected', 'label': 'Rejected'},
    ];

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
                            items: statusOptions.map((
                              Map<String, String> status,
                            ) {
                              return DropdownMenuItem<String>(
                                value: status['value'],
                                child: Text(status['label']!),
                              );
                            }).toList(),
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
                          // Image selection section
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
                                    Expanded(
                                      child: Text(
                                        'Attach Response Images (Optional)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  existingImageCount > 0
                                      ? 'Existing response images ($existingImageCount/3):'
                                      : 'Add up to 3 images to show the user how the issue was resolved',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (existingImageCount > 0) ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 60,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _adminResponseImages.length,
                                      itemBuilder: (context, index) {
                                        final image =
                                            _adminResponseImages[index];
                                        return Container(
                                          margin: EdgeInsets.only(
                                            right:
                                                index <
                                                    _adminResponseImages
                                                            .length -
                                                        1
                                                ? 8
                                                : 0,
                                          ),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: AppColors.primaryGreen
                                                    .withValues(alpha: 0.3),
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: image.imageData.isNotEmpty
                                                  ? Image.memory(
                                                      Uint8List.fromList(
                                                        _reportsService
                                                            .base64ToBytes(
                                                              image.imageData,
                                                            ),
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: AppColors
                                                                  .textSecondary
                                                                  .withValues(
                                                                    alpha: 0.1,
                                                                  ),
                                                              child: const Icon(
                                                                Icons
                                                                    .broken_image,
                                                                color: AppColors
                                                                    .textSecondary,
                                                                size: 20,
                                                              ),
                                                            );
                                                          },
                                                    )
                                                  : Container(
                                                      color: AppColors
                                                          .textSecondary
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: AppColors
                                                            .textSecondary,
                                                        size: 20,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  if (existingImageCount < 3) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add up to ${3 - existingImageCount} more images:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                                const SizedBox(height: 12),
                                if (selectedImages.isEmpty)
                                  GestureDetector(
                                    onTap: existingImageCount >= 3
                                        ? null
                                        : () async {
                                            try {
                                              final images = await imagePicker
                                                  .pickMultiImage(
                                                    imageQuality: 70,
                                                  );
                                              if (images.isNotEmpty) {
                                                // Limit based on existing images
                                                final availableSlots =
                                                    3 - existingImageCount;
                                                final limitedImages = images
                                                    .take(availableSlots)
                                                    .toList();
                                                setDialogState(() {
                                                  selectedImages =
                                                      limitedImages;
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
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: existingImageCount >= 3
                                                ? AppColors.textSecondary
                                                : AppColors.primaryGreen,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            existingImageCount >= 3
                                                ? 'Maximum images reached (3/3)'
                                                : 'Tap to select images',
                                            style: TextStyle(
                                              color: existingImageCount >= 3
                                                  ? AppColors.textSecondary
                                                  : AppColors.primaryGreen,
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
                                      if (selectedImages.length +
                                              existingImageCount <
                                          3)
                                        GestureDetector(
                                          onTap: () async {
                                            try {
                                              final remainingSlots =
                                                  3 -
                                                  selectedImages.length -
                                                  existingImageCount;
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
                                                  'Add more (${selectedImages.length + existingImageCount}/3)',
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
                  onPressed: _isUpdatingStatus
                      ? null
                      : () {
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
                            _updateReportStatus(
                              newStatus,
                              notesController.text.trim(),
                              selectedImages.isNotEmpty ? selectedImages : null,
                              adminNameController.text.trim().isNotEmpty
                                  ? adminNameController.text.trim()
                                  : null,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdatingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Update Status'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showImageDialog(ReportImage image) {
    if (image.imageData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image data available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  Uint8List.fromList(
                    _reportsService.base64ToBytes(image.imageData),
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Size: ${_reportsService.formatFileSize(image.fileSize)} • Type: ${image.imageType.toUpperCase()}',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    Widget? trailing,
  }) {
    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (!_currentReport.hasImage) return const SizedBox.shrink();

    return Container(
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
                  Icons.image_outlined,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached Images',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to view full size',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingImages)
            const Center(child: LoadingIndicator())
          else if (_imageError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _imageError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (_images.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No images found',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showImageDialog(image),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: image.imageData.isNotEmpty
                              ? Image.memory(
                                  Uint8List.fromList(
                                    _reportsService.base64ToBytes(
                                      image.imageData,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: AppColors.textSecondary,
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Error',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: AppColors.textSecondary,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'No Data',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdminResponseImagesSection() {
    if (!_currentReport.hasAdminResponseImage) return const SizedBox.shrink();

    return Container(
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
                  Icons.admin_panel_settings_outlined,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolution Images',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Response Images Attached',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingAdminImages)
            const Center(child: LoadingIndicator())
          else if (_adminImageError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _adminImageError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (_adminResponseImages.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No resolution images found',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _adminResponseImages.length,
                itemBuilder: (context, index) {
                  final image = _adminResponseImages[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _showAdminImageDialog(image),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: image.imageData.isNotEmpty
                              ? Image.memory(
                                  Uint8List.fromList(
                                    _reportsService.base64ToBytes(
                                      image.imageData,
                                    ),
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.textSecondary.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: AppColors.textSecondary,
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Error',
                                            style: TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        color: AppColors.textSecondary,
                                        size: 32,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'No Data',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAdminImageDialog(AdminResponseImage image) {
    if (image.imageData.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No image data available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.memory(
                  Uint8List.fromList(
                    _reportsService.base64ToBytes(image.imageData),
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Size: ${_reportsService.formatFileSize(image.fileSize)} • Type: ${image.imageType.toUpperCase()}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (image.adminName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded by: ${image.adminName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                _buildStatusBadge(_currentReport.status),
              ],
            ),
            const SizedBox(height: 24),

            // User Information
            _buildInfoCard(
              title: 'Reporter Name',
              value: _currentReport.fullName,
              icon: Icons.person_outline,
            ),

            _buildInfoCard(
              title: 'Phone Number',
              value: _currentReport.phone,
              icon: Icons.phone_outlined,
            ),

            _buildInfoCard(
              title: 'Location',
              value: '${_currentReport.barangay} Barangay',
              icon: Icons.location_on_outlined,
            ),

            _buildInfoCard(
              title: 'Submitted',
              value: _formatDateTime(_currentReport.createdAt),
              icon: Icons.access_time,
            ),

            _buildInfoCard(
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
            _buildImageSection(),

            // Admin Response Images Section
            _buildAdminResponseImagesSection(),

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
                  child: OutlinedButton.icon(
                    onPressed: _showStatusUpdateDialog,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update Status'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
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
                    icon: const Icon(Icons.phone_outlined, color: Colors.white),
                    label: const Text(
                      'Contact User',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
