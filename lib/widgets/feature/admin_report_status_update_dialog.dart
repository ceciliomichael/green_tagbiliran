import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';

class AdminReportStatusUpdateDialog extends StatefulWidget {
  final Report report;
  final Function(ReportStatus status, String? notes, List<XFile> images, String? adminName) onUpdate;

  const AdminReportStatusUpdateDialog({
    super.key,
    required this.report,
    required this.onUpdate,
  });

  @override
  State<AdminReportStatusUpdateDialog> createState() => _AdminReportStatusUpdateDialogState();
}

class _AdminReportStatusUpdateDialogState extends State<AdminReportStatusUpdateDialog> {
  late String? selectedStatus;
  late TextEditingController notesController;
  late TextEditingController adminNameController;
  final formKey = GlobalKey<FormState>();
  List<XFile> selectedImages = [];
  final imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.report.status.toString().split('.').last;
    if (selectedStatus == 'inProgress') selectedStatus = 'in_progress';
    notesController = TextEditingController(text: widget.report.adminNotes ?? '');
    adminNameController = TextEditingController();
  }

  @override
  void dispose() {
    notesController.dispose();
    adminNameController.dispose();
    super.dispose();
  }

  ReportStatus? _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return ReportStatus.pending;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return null;
    }
  }

  Future<void> _selectImages() async {
    try {
      final images = await imagePicker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() {
          selectedImages = images.take(3).toList();
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

  Future<void> _addMoreImages() async {
    try {
      final remainingSlots = 3 - selectedImages.length;
      final images = await imagePicker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() {
          selectedImages.addAll(images.take(remainingSlots).toList());
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
      selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildStatusDropdown(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 16),
                  _buildAdminNameField(),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
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
          onPressed: _handleUpdate,
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
          child: const Text(
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

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
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
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
      ],
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
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
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
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
    );
  }

  Widget _buildAdminNameField() {
    return TextFormField(
      controller: adminNameController,
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
        if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker() {
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
          const Text(
            'Add up to 3 images to show the user how the issue was resolved',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (selectedImages.isEmpty)
            _buildEmptyImagePicker()
          else
            _buildImageList(),
        ],
      ),
    );
  }

  Widget _buildEmptyImagePicker() {
    return GestureDetector(
      onTap: _selectImages,
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _buildImageList() {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(
                  right: index < selectedImages.length - 1 ? 8 : 0,
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
                          future: selectedImages[index].readAsBytes(),
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
        if (selectedImages.length < 3)
          GestureDetector(
            onTap: _addMoreImages,
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
                    'Add more (${selectedImages.length}/3)',
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

  void _handleUpdate() {
    if (formKey.currentState!.validate()) {
      final status = _parseStatus(selectedStatus);
      if (status != null) {
        Navigator.pop(context);
        widget.onUpdate(
          status,
          notesController.text.trim(),
          selectedImages,
          adminNameController.text.trim().isNotEmpty
              ? adminNameController.text.trim()
              : null,
        );
      }
    }
  }
}

