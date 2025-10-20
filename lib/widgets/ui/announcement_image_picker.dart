import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';

class AnnouncementImagePicker extends StatelessWidget {
  final XFile? selectedImage;
  final bool removeExistingImage;
  final bool hasExistingImage;
  final Function(XFile?) onImageSelected;
  final Function(bool) onRemoveToggled;

  const AnnouncementImagePicker({
    super.key,
    required this.selectedImage,
    required this.onImageSelected,
    this.removeExistingImage = false,
    this.hasExistingImage = false,
    required this.onRemoveToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(
                hasExistingImage ? 'Image' : 'Image (Optional)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasExistingImage && !removeExistingImage && selectedImage == null) ...[
            const Text('Current image will be kept'),
            const SizedBox(height: 8),
          ],
          if (selectedImage != null) ...[
            const SizedBox(height: 8),
            _buildImagePreview(),
            const SizedBox(height: 8),
            Text(
              hasExistingImage 
                ? 'New image selected: ${selectedImage!.name}'
                : 'Selected: ${selectedImage!.name}',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],
          if (removeExistingImage) ...[
            Text(
              'Current image will be removed',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
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
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final imagePicker = ImagePicker();
    
    return Wrap(
      spacing: 8,
      children: [
        TextButton.icon(
          onPressed: () async {
            final image = await imagePicker.pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              onImageSelected(image);
              if (removeExistingImage) {
                onRemoveToggled(false);
              }
            }
          },
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
        TextButton.icon(
          onPressed: () async {
            final image = await imagePicker.pickImage(
              source: ImageSource.camera,
            );
            if (image != null) {
              onImageSelected(image);
              if (removeExistingImage) {
                onRemoveToggled(false);
              }
            }
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
        ),
        if (hasExistingImage)
          TextButton.icon(
            onPressed: () {
              onRemoveToggled(!removeExistingImage);
              if (!removeExistingImage) {
                onImageSelected(null);
              }
            },
            icon: Icon(
              removeExistingImage ? Icons.undo : Icons.delete_outline,
              color: removeExistingImage ? AppColors.primaryGreen : AppColors.error,
            ),
            label: Text(
              removeExistingImage ? 'Keep Image' : 'Remove Image',
              style: TextStyle(
                color: removeExistingImage ? AppColors.primaryGreen : AppColors.error,
              ),
            ),
          ),
        if (selectedImage != null && !hasExistingImage)
          TextButton.icon(
            onPressed: () => onImageSelected(null),
            icon: const Icon(Icons.clear),
            label: const Text('Remove'),
          ),
        if (selectedImage != null && hasExistingImage)
          TextButton.icon(
            onPressed: () => onImageSelected(null),
            icon: const Icon(Icons.clear),
            label: const Text('Clear New'),
          ),
      ],
    );
  }
}

