import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import 'report_instruction_step.dart';

class ReportImageAttachment extends StatelessWidget {
  final List<XFile> selectedImages;
  final int maxImages;
  final VoidCallback onPickImage;
  final Function(int) onRemoveImage;
  final VoidCallback onShowSample;

  const ReportImageAttachment({
    super.key,
    required this.selectedImages,
    required this.maxImages,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onShowSample,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attach Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${selectedImages.length}/$maxImages',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPhotoInstructions(),
            if (selectedImages.length < maxImages) ...[
              _buildAddPhotoButton(),
              const SizedBox(height: 16),
            ],
            if (selectedImages.isNotEmpty) ..._buildSelectedImages(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'IMPORTANT: Photo Requirements',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'How to properly take report photos:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const ReportInstructionStep(
            stepNumber: '1',
            instruction: 'Open Camera → Settings → Enable Location',
          ),
          const ReportInstructionStep(
            stepNumber: '2',
            instruction: 'Take a photo of the issue with live location visible',
          ),
          const ReportInstructionStep(
            stepNumber: '3',
            instruction: 'Screenshot the photo showing location data',
          ),
          const ReportInstructionStep(
            stepNumber: '4',
            instruction: 'Upload the screenshot (must include location proof)',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShowSample,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text(
                'View Sample Photo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: BorderSide(
                  color: AppColors.primaryGreen.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Photos without location will result in report dismissal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
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

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(
            color: AppColors.textSecondary.withValues(alpha: 0.4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                size: 28,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap to select a photo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Optional: Add up to $maxImages photos',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectedImages() {
    return List.generate(selectedImages.length, (index) {
      final image = selectedImages[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceWhite,
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
                child: kIsWeb
                    ? Image.network(
                        image.path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.surfaceWhite,
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                    : FutureBuilder<Uint8List>(
                        future: image.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          } else if (snapshot.hasError) {
                            return Container(
                              color: AppColors.surfaceWhite,
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 48,
                                ),
                              ),
                            );
                          } else {
                            return Container(
                              color: AppColors.surfaceWhite,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => onRemoveImage(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

