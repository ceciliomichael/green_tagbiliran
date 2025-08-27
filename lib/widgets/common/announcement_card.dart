import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/announcement.dart';
import '../../services/announcements_service.dart';
import '../../screens/announcements/announcement_detail_screen.dart';

class AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, 3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                announcement: announcement,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and admin actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                announcement.createdByName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                announcement.formattedDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.primaryGreen,
                              ),
                              const SizedBox(width: 8),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                announcement.description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              
              // Image if available
              if (announcement.hasImage) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildAnnouncementImage(),
                ),
              ],
              
              // Footer with engagement indicators
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Official Announcement',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementImage() {
    if (!announcement.hasImage) {
      return const SizedBox.shrink();
    }

    try {
      // Decode base64 image
      final imageBytes = AnnouncementsService().base64ToImage(announcement.imageUrl!);
      
      return Container(
        width: double.infinity,
        height: 200, // Fixed square-like height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image failed to load',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Invalid image format',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
