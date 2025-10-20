import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../services/announcements_service.dart';
import '../../services/auth_service.dart';
import '../ui/announcement_form_fields.dart';
import '../ui/announcement_image_picker.dart';

class EditAnnouncementDialog extends StatefulWidget {
  final Announcement announcement;
  final VoidCallback onSuccess;

  const EditAnnouncementDialog({
    super.key,
    required this.announcement,
    required this.onSuccess,
  });

  @override
  State<EditAnnouncementDialog> createState() => _EditAnnouncementDialogState();
}

class _EditAnnouncementDialogState extends State<EditAnnouncementDialog> {
  final AnnouncementsService _announcementsService = AnnouncementsService();
  final AuthService _authService = AuthService();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  XFile? _selectedImage;
  bool _isUpdating = false;
  bool _removeImage = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement.title);
    _descriptionController = TextEditingController(text: widget.announcement.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.updateAnnouncement(
        announcementId: widget.announcement.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: currentUser.id,
        imageFile: _selectedImage,
        removeImage: _removeImage,
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Announcement updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to update announcement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: EdgeInsets.zero,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      content: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Edit Announcement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnnouncementFormFields(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                    ),
                    const SizedBox(height: 16),
                    AnnouncementImagePicker(
                      selectedImage: _selectedImage,
                      hasExistingImage: widget.announcement.hasImage,
                      removeExistingImage: _removeImage,
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                      onRemoveToggled: (shouldRemove) {
                        setState(() {
                          _removeImage = shouldRemove;
                          if (shouldRemove) _selectedImage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isUpdating ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isUpdating ? null : _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Update Announcement'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

