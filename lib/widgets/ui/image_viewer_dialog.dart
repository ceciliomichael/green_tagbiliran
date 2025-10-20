import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';

class ImageViewerDialog extends StatelessWidget {
  final String imageData;
  final String? fileSize;
  final String? imageType;
  final String? adminName;

  const ImageViewerDialog({
    super.key,
    required this.imageData,
    this.fileSize,
    this.imageType,
    this.adminName,
  });

  factory ImageViewerDialog.fromReportImage(ReportImage image) {
    return ImageViewerDialog(
      imageData: image.imageData,
      fileSize: ReportsService().formatFileSize(image.fileSize),
      imageType: image.imageType.toUpperCase(),
    );
  }

  factory ImageViewerDialog.fromAdminResponseImage(AdminResponseImage image) {
    return ImageViewerDialog(
      imageData: image.imageData,
      fileSize: ReportsService().formatFileSize(image.fileSize),
      imageType: image.imageType.toUpperCase(),
      adminName: image.adminName,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageData.isEmpty) {
      return AlertDialog(
        content: const Text('No image data available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    final reportsService = ReportsService();

    return Dialog(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: Image.memory(
                Uint8List.fromList(reportsService.base64ToBytes(imageData)),
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
          if (fileSize != null || imageType != null || adminName != null)
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
                    if (fileSize != null && imageType != null)
                      Text(
                        'Size: $fileSize • Type: $imageType',
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    if (adminName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded by: $adminName',
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
    );
  }
}

