import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../services/announcements_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/announcement_card.dart';
import '../../widgets/common/loading_indicator.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final AnnouncementsService _announcementsService = AnnouncementsService();
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.getAnnouncementsByAdmin(currentUser.id);
      
      if (result.success && result.announcements != null) {
        setState(() {
          _announcements = result.announcements!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error ?? 'Failed to load announcements';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading announcements: ${e.toString()}';
        _isLoading = false;
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
              'Announcements & Events',
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
          'Create and manage community announcements and events',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAnnouncementButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _showCreateAnnouncementDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 24),
            SizedBox(width: 12),
            Text(
              'Create New Announcement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    XFile? selectedImage;
    bool isCreating = false;

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
                                       key: formKey,
                       child: Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 24),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             TextFormField(
                               controller: titleController,
                               decoration: InputDecoration(
                                labelText: 'Announcement Title',
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
                               validator: (value) {
                                 if (value == null || value.isEmpty) {
                                  return 'Please enter announcement title';
                                 }
                                 return null;
                               },
                             ),
                             const SizedBox(height: 16),
                             TextFormField(
                               controller: descriptionController,
                              maxLines: 4,
                               decoration: InputDecoration(
                                labelText: 'Announcement Description',
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
                               validator: (value) {
                                 if (value == null || value.isEmpty) {
                                  return 'Please enter announcement description';
                                 }
                                 return null;
                               },
                             ),
                             const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                 color: AppColors.primaryGreen,
                               ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Image (Optional)',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (selectedImage != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: FutureBuilder<Uint8List>(
                                          future: selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 120,
                                              );
                                            } else if (snapshot.hasError) {
                                              return Container(
                                                color: AppColors.surfaceWhite,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.error_outline,
                                                        color: AppColors.error,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Error loading image',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                color: AppColors.surfaceWhite,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        AppColors.primaryGreen,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Selected: ${selectedImage!.name}',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Row(
                                    children: [
                                      TextButton.icon(
                                        onPressed: () async {
                                          final image = await _imagePicker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (image != null) {
                                            setDialogState(() {
                                              selectedImage = image;
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.photo_library),
                                        label: const Text('Gallery'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          final image = await _imagePicker.pickImage(
                                            source: ImageSource.camera,
                                          );
                                          if (image != null) {
                                   setDialogState(() {
                                              selectedImage = image;
                                   });
                                 }
                               },
                                        icon: const Icon(Icons.camera_alt),
                                        label: const Text('Camera'),
                                      ),
                                      if (selectedImage != null)
                                        TextButton.icon(
                                          onPressed: () {
                                            setDialogState(() {
                                              selectedImage = null;
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Remove'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: isCreating ? null : () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: isCreating ? null : () async {
                                    if (formKey.currentState!.validate()) {
                                      setDialogState(() {
                                        isCreating = true;
                                      });

                                      try {
                                        final currentUser = _authService.currentUser;
                                        if (currentUser == null) {
                                          throw Exception('User not authenticated');
                                        }

                                        final result = await _announcementsService.createAnnouncement(
                                          title: titleController.text.trim(),
                                          description: descriptionController.text.trim(),
                                          createdBy: currentUser.id,
                                          imageFile: selectedImage,
                                        );

                                        if (result.success) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result.message ?? 'Announcement created successfully!'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                          _loadAnnouncements();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result.error ?? 'Failed to create announcement'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: ${e.toString()}'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      } finally {
                                        setDialogState(() {
                                          isCreating = false;
                                        });
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
                                  child: isCreating
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
          },
        );
      },
    );
  }

  void _showEditAnnouncementDialog(Announcement announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final descriptionController = TextEditingController(text: announcement.description);
    final formKey = GlobalKey<FormState>();
    XFile? selectedImage;
    bool isUpdating = false;
    bool removeImage = false;

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
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Announcement Title',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter announcement title';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Announcement Description',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter announcement description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                 color: AppColors.primaryGreen,
                               ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Image',
                                        style: TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (announcement.hasImage && !removeImage) ...[
                                    const Text('Current image will be kept'),
                                    const SizedBox(height: 8),
                                  ],
                                  if (selectedImage != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: FutureBuilder<Uint8List>(
                                          future: selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 120,
                                              );
                                            } else if (snapshot.hasError) {
                                              return Container(
                                                color: AppColors.surfaceWhite,
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.error_outline,
                                                        color: AppColors.error,
                                                        size: 24,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Error loading image',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: AppColors.error,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                color: AppColors.surfaceWhite,
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        AppColors.primaryGreen,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'New image selected: ${selectedImage!.name}',
                                      style: TextStyle(
                                        color: AppColors.primaryGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (removeImage) ...[
                                    Text(
                                      'Current image will be removed',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () async {
                                          final image = await _imagePicker.pickImage(
                                            source: ImageSource.gallery,
                                          );
                                          if (image != null) {
                                            setDialogState(() {
                                              selectedImage = image;
                                              removeImage = false;
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.photo_library),
                                        label: const Text('Gallery'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () async {
                                          final image = await _imagePicker.pickImage(
                                            source: ImageSource.camera,
                                          );
                                          if (image != null) {
                                   setDialogState(() {
                                              selectedImage = image;
                                              removeImage = false;
                                   });
                                 }
                               },
                                        icon: const Icon(Icons.camera_alt),
                                        label: const Text('Camera'),
                                      ),
                                      if (announcement.hasImage)
                                        TextButton.icon(
                                          onPressed: () {
                                            setDialogState(() {
                                              removeImage = !removeImage;
                                              if (removeImage) selectedImage = null;
                                            });
                                          },
                                          icon: Icon(
                                            removeImage ? Icons.undo : Icons.delete_outline,
                                            color: removeImage ? AppColors.primaryGreen : AppColors.error,
                                          ),
                                          label: Text(
                                            removeImage ? 'Keep Image' : 'Remove Image',
                                            style: TextStyle(
                                              color: removeImage ? AppColors.primaryGreen : AppColors.error,
                                            ),
                                          ),
                                        ),
                                      if (selectedImage != null)
                                        TextButton.icon(
                                          onPressed: () {
                                            setDialogState(() {
                                              selectedImage = null;
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                          label: const Text('Clear New'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                             ),
                             const SizedBox(height: 24),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                                 TextButton(
                                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                                   child: const Text(
                                     'Cancel',
                                     style: TextStyle(color: AppColors.textSecondary),
                                   ),
                                 ),
                                 const SizedBox(width: 16),
                                 ElevatedButton(
                                  onPressed: isUpdating ? null : () async {
                                     if (formKey.currentState!.validate()) {
                                      setDialogState(() {
                                        isUpdating = true;
                                      });

                                      try {
                                        final currentUser = _authService.currentUser;
                                        if (currentUser == null) {
                                          throw Exception('User not authenticated');
                                        }

                                        final result = await _announcementsService.updateAnnouncement(
                                          announcementId: announcement.id,
                                          title: titleController.text.trim(),
                                          description: descriptionController.text.trim(),
                                          userId: currentUser.id,
                                          imageFile: selectedImage,
                                          removeImage: removeImage,
                                        );

                                        if (result.success) {
                                       Navigator.pop(context);
                                       ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result.message ?? 'Announcement updated successfully!'),
                                           backgroundColor: AppColors.success,
                                         ),
                                       );
                                          _loadAnnouncements();
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result.error ?? 'Failed to update announcement'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: ${e.toString()}'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      } finally {
                                        setDialogState(() {
                                          isUpdating = false;
                                        });
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
                                  child: isUpdating
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
           },
         );
       },
     );
  }

  void _showDeleteConfirmationDialog(Announcement announcement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Announcement',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${announcement.title}"? This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary),
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
                Navigator.pop(context);
                await _deleteAnnouncement(announcement);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAnnouncement(Announcement announcement) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await _announcementsService.deleteAnnouncement(
        announcementId: announcement.id,
        userId: currentUser.id,
      );

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Announcement deleted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadAnnouncements();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to delete announcement'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildAnnouncementsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: LoadingIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAnnouncements,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_announcements.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Your Announcements (${_announcements.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_announcements.map((announcement) => AnnouncementCard(
            announcement: announcement,
            isAdmin: true,
            onEdit: () => _showEditAnnouncementDialog(announcement),
            onDelete: () => _showDeleteConfirmationDialog(announcement),
          )).toList()),
          const SizedBox(height: 40),
        ],
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
              Icons.event_outlined,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Events Created',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create community events and reminders that will be visible to all users in the app. Events help keep the community informed about important activities.',
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
                     'Click "Create New Event" to get started',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Column(
          children: [
          _buildHeader(),
          _buildCreateAnnouncementButton(),
          Expanded(
            child: SingleChildScrollView(
              child: _buildAnnouncementsList(),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
