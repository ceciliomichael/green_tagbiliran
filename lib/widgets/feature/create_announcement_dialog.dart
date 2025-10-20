import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../services/announcements_service.dart';
import '../../services/auth_service.dart';
import '../ui/announcement_form_fields.dart';
import '../ui/announcement_image_picker.dart';

class CreateAnnouncementDialog extends StatefulWidget {
  final VoidCallback onSuccess;

  const CreateAnnouncementDialog({
    super.key,
    required this.onSuccess,
  });

  @override
  State<CreateAnnouncementDialog> createState() => _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<CreateAnnouncementDialog> {
  final AnnouncementsService _announcementsService = AnnouncementsService();
  final AuthService _authService = AuthService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  XFile? _selectedImage;
  bool _isCreating = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.createAnnouncement(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdBy: currentUser.id,
        imageFile: _selectedImage,
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Announcement created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to create announcement'),
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
          _isCreating = false;
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
              'Create New Announcement',
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
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                      onRemoveToggled: (_) {},
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isCreating ? null : () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isCreating ? null : _handleCreate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Create Announcement'),
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

