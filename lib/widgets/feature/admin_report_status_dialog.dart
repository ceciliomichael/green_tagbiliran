import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';

class AdminReportStatusDialog extends StatefulWidget {
  final Report currentReport;
  final List<AdminResponseImage> adminResponseImages;
  final Function(
    ReportStatus newStatus,
    String? notes,
    List<XFile>? responseImages,
    String? adminName,
  ) onUpdateStatus;
  final bool isUpdating;

  const AdminReportStatusDialog({
    super.key,
    required this.currentReport,
    required this.adminResponseImages,
    required this.onUpdateStatus,
    required this.isUpdating,
  });

  @override
  State<AdminReportStatusDialog> createState() =>
      _AdminReportStatusDialogState();
}

class _AdminReportStatusDialogState extends State<AdminReportStatusDialog> {
  final _reportsService = ReportsService();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late TextEditingController _notesController;
  late TextEditingController _adminNameController;
  late String? _selectedStatus;
  final List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    String? initialStatus =
        widget.currentReport.status.toString().split('.').last;
    if (initialStatus == 'inProgress') initialStatus = 'in_progress';

    _selectedStatus = initialStatus;
    _notesController = TextEditingController(
      text: widget.currentReport.adminNotes ?? '',
    );
    _adminNameController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final availableSlots =
          3 - widget.adminResponseImages.length - _selectedImages.length;
      if (availableSlots <= 0) return;

      final images = await _imagePicker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        final limitedImages = images.take(availableSlots).toList();
        setState(() {
          _selectedImages.addAll(limitedImages);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select images: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitUpdate() {
    if (_formKey.currentState!.validate()) {
      ReportStatus newStatus;
      switch (_selectedStatus) {
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
      widget.onUpdateStatus(
        newStatus,
        _notesController.text.trim(),
        _selectedImages.isNotEmpty ? _selectedImages : null,
        _adminNameController.text.trim().isNotEmpty
            ? _adminNameController.text.trim()
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingImageCount = widget.adminResponseImages.length;
    final statusOptions = [
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'resolved', 'label': 'Resolved'},
      {'value': 'rejected', 'label': 'Rejected'},
    ];

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
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusDropdown(statusOptions),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 16),
                  _buildAdminNameField(),
                  const SizedBox(height: 16),
                  _buildImageSection(existingImageCount),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: widget.isUpdating ? null : _submitUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: widget.isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Update',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(List<Map<String, String>> statusOptions) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedStatus,
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
      items: statusOptions.map((Map<String, String> status) {
        return DropdownMenuItem<String>(
          value: status['value'],
          child: Text(status['label']!),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a status';
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
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
    );
  }

  Widget _buildAdminNameField() {
    return TextFormField(
      controller: _adminNameController,
      decoration: InputDecoration(
        labelText: 'Your Name (Optional)',
        hintText: 'Enter your name so the user knows who resolved their issue...',
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
    );
  }

  Widget _buildImageSection(int existingImageCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
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
          Text(
            existingImageCount > 0
                ? 'Existing response images ($existingImageCount/3):'
                : 'Add up to 3 images to show the user how the issue was resolved',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (existingImageCount > 0) ...[
            const SizedBox(height: 8),
            _buildExistingImagesPreview(),
            if (existingImageCount < 3) ...[
              const SizedBox(height: 8),
              Text(
                'Add up to ${3 - existingImageCount} more images:',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          if (_selectedImages.isEmpty)
            _buildImagePickerButton(existingImageCount)
          else
            _buildSelectedImagesPreview(existingImageCount),
        ],
      ),
    );
  }

  Widget _buildExistingImagesPreview() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.adminResponseImages.length,
        itemBuilder: (context, index) {
          final image = widget.adminResponseImages[index];
          return Container(
            margin: EdgeInsets.only(
              right: index < widget.adminResponseImages.length - 1 ? 8 : 0,
            ),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: image.imageData.isNotEmpty
                  ? Image.memory(
                      Uint8List.fromList(
                        _reportsService.base64ToBytes(image.imageData),
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.textSecondary.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePickerButton(int existingImageCount) {
    final isDisabled = existingImageCount >= 3;
    return GestureDetector(
      onTap: isDisabled ? null : _pickImages,
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: isDisabled
                  ? AppColors.textSecondary
                  : AppColors.primaryGreen,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isDisabled
                  ? 'Maximum images reached (3/3)'
                  : 'Tap to select images',
              style: TextStyle(
                color: isDisabled
                    ? AppColors.textSecondary
                    : AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImagesPreview(int existingImageCount) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(
                  right: index < _selectedImages.length - 1 ? 8 : 0,
                ),
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImages[index].readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
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
        if (_selectedImages.length + existingImageCount < 3)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
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
                    'Add more (${_selectedImages.length + existingImageCount}/3)',
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

