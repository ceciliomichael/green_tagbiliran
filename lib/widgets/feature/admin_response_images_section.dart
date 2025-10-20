import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';
import '../common/loading_indicator.dart';

class AdminResponseImagesSection extends StatelessWidget {
  final Report report;
  final List<AdminResponseImage> adminResponseImages;
  final bool isLoading;
  final String? error;
  final Function(AdminResponseImage) onImageTap;

  const AdminResponseImagesSection({
    super.key,
    required this.report,
    required this.adminResponseImages,
    required this.isLoading,
    this.error,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!report.hasAdminResponseImage) return const SizedBox.shrink();

    final reportsService = ReportsService();

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
          if (isLoading)
            const Center(child: LoadingIndicator())
          else if (error != null)
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
                    error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (adminResponseImages.isEmpty)
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
                itemCount: adminResponseImages.length,
                itemBuilder: (context, index) {
                  final image = adminResponseImages[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => onImageTap(image),
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: image.imageData.isNotEmpty
                              ? Image.memory(
                                  Uint8List.fromList(
                                    reportsService.base64ToBytes(image.imageData),
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
}

