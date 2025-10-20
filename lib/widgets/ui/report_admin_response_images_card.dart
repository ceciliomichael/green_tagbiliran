import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/report.dart';
import '../../services/reports_service.dart';
import '../../widgets/common/loading_indicator.dart';
import 'report_image_viewer_dialog.dart';

class ReportAdminResponseImagesCard extends StatefulWidget {
  final String reportId;
  final String userId;
  final bool hasAdminResponseImage;

  const ReportAdminResponseImagesCard({
    super.key,
    required this.reportId,
    required this.userId,
    required this.hasAdminResponseImage,
  });

  @override
  State<ReportAdminResponseImagesCard> createState() =>
      _ReportAdminResponseImagesCardState();
}

class _ReportAdminResponseImagesCardState
    extends State<ReportAdminResponseImagesCard> {
  final _reportsService = ReportsService();
  List<AdminResponseImage> _adminResponseImages = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.hasAdminResponseImage) {
      _loadAdminResponseImages();
    }
  }

  Future<void> _loadAdminResponseImages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _reportsService.getAdminResponseImages(
        userId: widget.userId,
        reportId: widget.reportId,
      );

      if (result.success && result.adminResponseImages != null) {
        if (mounted) {
          setState(() {
            _adminResponseImages = result.adminResponseImages!;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = result.error ?? 'Failed to load admin response images';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load admin response images: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _showImageFullScreen(AdminResponseImage image) {
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
    if (!widget.hasAdminResponseImage) return const SizedBox.shrink();

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
              Icon(
                Icons.photo_library_outlined,
                size: 20,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolution Images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Images showing how your issue was resolved',
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
          else if (_adminResponseImages.isEmpty)
            _buildEmptyState()
          else
            _buildImagesContent(),
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
        'No resolution images found',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImagesContent() {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _adminResponseImages.length,
            itemBuilder: (context, index) {
              final image = _adminResponseImages[index];
              return Container(
                margin: EdgeInsets.only(
                  right: index < _adminResponseImages.length - 1 ? 12 : 0,
                ),
                child: GestureDetector(
                  onTap: () => _showImageFullScreen(image),
                  child: _buildImageThumbnail(image),
                ),
              );
            },
          ),
        ),
        if (_adminResponseImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Tap any image to view full size',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageThumbnail(AdminResponseImage image) {
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

