part of '../reports_service.dart';

extension ReportsImageOperations on ReportsService {
  // Get report images
  Future<ReportsResult> getReportImages({
    required String userId,
    required String reportId,
  }) async {
    try {
      final requestBody = {'p_user_id': userId, 'p_report_id': reportId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.getReportImagesEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final imagesJson = responseData['images'] as List<dynamic>?;
          final images = <ReportImage>[];

          if (imagesJson != null) {
            for (final imageJson in imagesJson) {
              try {
                if (imageJson is Map<String, dynamic>) {
                  final image = ReportImage.fromJson(imageJson);
                  images.add(image);
                }
              } catch (e) {
                debugPrint('Error parsing image: $e');
                debugPrint('Image JSON: $imageJson');
                // Skip this image and continue with others
                continue;
              }
            }
          }

          return ReportsResult(success: true, images: images);
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get images',
          );
        }
      } else {
        return ReportsResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ReportsResult(
        success: false,
        error: 'Failed to get images: ${e.toString()}',
      );
    }
  }

  // Get admin response images for a report
  Future<ReportsResult> getAdminResponseImages({
    required String userId,
    required String reportId,
  }) async {
    try {
      final requestBody = {'p_user_id': userId, 'p_report_id': reportId};

      final response = await http.post(
        Uri.parse(SupabaseConfig.getAdminResponseImagesEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final imagesJson = responseData['images'] as List<dynamic>?;
          final images = <AdminResponseImage>[];

          if (imagesJson != null) {
            for (final imageJson in imagesJson) {
              try {
                if (imageJson is Map<String, dynamic>) {
                  final image = AdminResponseImage.fromJson(imageJson);
                  images.add(image);
                }
              } catch (e) {
                debugPrint('Error parsing admin response image: $e');
                debugPrint('Image JSON: $imageJson');
                // Skip this image and continue with others
                continue;
              }
            }
          }

          return ReportsResult(success: true, adminResponseImages: images);
        } else {
          return ReportsResult(
            success: false,
            error:
                responseData['error'] ?? 'Failed to get admin response images',
          );
        }
      } else {
        return ReportsResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ReportsResult(
        success: false,
        error: 'Failed to get admin response images: ${e.toString()}',
      );
    }
  }

  // Convert base64 to image bytes for display
  List<int> base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  // Get file size in human readable format
  String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

