import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';
import '../../widgets/common/loading_indicator.dart';
import 'report_image_viewer_dialog.dart';

class ReportImagesCard extends StatefulWidget {
  final String reportId;
  final String userId;
  final bool hasImage;

  const ReportImagesCard({
    super.key,
    required this.reportId,
    required this.userId,
    required this.hasImage,
  });

  @override
  State<ReportImagesCard> createState() => _ReportImagesCardState();
}

class _ReportImagesCardState extends State<ReportImagesCard> {
  final _reportsService = ReportsService();
  List<ReportImage> _images = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.hasImage) {
      _loadImages();
    }
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reportsService.getReportImages(
        userId: widget.userId,
        reportId: widget.reportId,
      );

      if (result.success && result.images != null) {
        if (mounted) {
          setState(() {
            _images = result.images!;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = result.error ?? 'Failed to load images';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load images: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _showImageFullScreen(ReportImage image) {
    if (image.imageData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image data is empty')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReportImageViewerDialog(
        imageBytes: Uint8List.fromList(
          _reportsService.base64ToBytes(image.imageData),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasImage) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
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
              const Icon(
                Icons.image_outlined,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attached Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap to view full size',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: LoadingIndicator())
          else if (_error != null)
            _buildErrorState(_error!)
          else if (_images.isEmpty)
            _buildEmptyState()
          else
            _buildImagesList(),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
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
            error,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'No images found',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImagesList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          final image = _images[index];
          return Container(
            margin: EdgeInsets.only(
              right: index < _images.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () => _showImageFullScreen(image),
              child: _buildImageThumbnail(image),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageThumbnail(ReportImage image) {
    return Container(
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
                  _reportsService.base64ToBytes(image.imageData),
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageError();
                },
              )
            : _buildImageNoData(),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: AppColors.textSecondary.withValues(alpha: 0.1),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
  }

  Widget _buildImageNoData() {
    return Container(
      color: AppColors.textSecondary.withValues(alpha: 0.1),
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
    );
  }
}

