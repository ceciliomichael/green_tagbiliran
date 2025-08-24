import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/report.dart';
import '../models/user.dart';
import '../constants/supabase_config.dart';
import 'package:flutter/foundation.dart';

class ReportsResult {
  final bool success;
  final String? error;
  final List<Report>? reports;
  final Report? report;
  final List<ReportImage>? images;
  final String? message;
  final int? totalCount;

  ReportsResult({
    required this.success,
    this.error,
    this.reports,
    this.report,
    this.images,
    this.message,
    this.totalCount,
  });
}

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  // Submit a report with optional image
  Future<ReportsResult> submitReport({
    required User user,
    required String fullName,
    required String phone,
    required String barangay,
    required String issueDescription,
    XFile? image,
  }) async {
    try {
      String? imageData;
      String? imageType;
      int? fileSize;

      // Convert image to base64 if provided
      if (image != null) {
        final bytes = await image.readAsBytes();
        imageData = base64Encode(bytes);
        imageType = _getImageType(image.path);
        fileSize = bytes.length;
      }

      // Prepare request body
      final requestBody = {
        'p_user_id': user.id,
        'p_full_name': fullName,
        'p_phone': phone,
        'p_barangay': barangay,
        'p_issue_description': issueDescription,
        if (imageData != null) 'p_image_data': imageData,
        if (imageType != null) 'p_image_type': imageType,
        if (fileSize != null) 'p_file_size': fileSize,
      };

      // Make HTTP request
      final response = await http.post(
        Uri.parse(SupabaseConfig.submitReportEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return ReportsResult(success: true, message: responseData['message']);
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Report submission failed',
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
        error: 'Report submission failed: ${e.toString()}',
      );
    }
  }

  // Get all reports (admin only)
  Future<ReportsResult> getAllReports({
    required String adminId,
    String? status,
    String? barangay,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final requestBody = {
        'p_admin_id': adminId,
        if (status != null) 'p_status': status,
        if (barangay != null) 'p_barangay': barangay,
        'p_limit': limit,
        'p_offset': offset,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.getAllReportsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final reportsJson = responseData['reports'] as List<dynamic>?;
          final reports =
              reportsJson
                  ?.map((json) => Report.fromJson(json as Map<String, dynamic>))
                  .toList() ??
              [];

          return ReportsResult(
            success: true,
            reports: reports,
            totalCount: responseData['total_count'] as int?,
          );
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get reports',
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
        error: 'Failed to get reports: ${e.toString()}',
      );
    }
  }

  // Update report status (admin only)
  Future<ReportsResult> updateReportStatus({
    required String adminId,
    required String reportId,
    required String status,
    String? adminNotes,
  }) async {
    try {
      final requestBody = {
        'p_admin_id': adminId,
        'p_report_id': reportId,
        'p_status': status,
        if (adminNotes != null) 'p_admin_notes': adminNotes,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.updateReportStatusEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return ReportsResult(success: true, message: responseData['message']);
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update report',
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
        error: 'Failed to update report: ${e.toString()}',
      );
    }
  }

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

  // Helper method to get image type from file path
  String _getImageType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg'; // Default to jpeg
    }
  }

  // Convert base64 to image bytes for display
  List<int> base64ToBytes(String base64String) {
    return base64Decode(base64String);
  }

  // Get user's own reports
  Future<ReportsResult> getUserReports({
    required String userId,
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final requestBody = {
        'p_user_id': userId,
        if (status != null) 'p_status': status,
        'p_limit': limit,
        'p_offset': offset,
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.getUserReportsEndpoint),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final reportsJson = responseData['reports'] as List<dynamic>?;
          final reports =
              reportsJson
                  ?.map((json) => Report.fromJson(json as Map<String, dynamic>))
                  .toList() ??
              [];

          return ReportsResult(
            success: true,
            reports: reports,
            totalCount: responseData['total_count'] as int?,
          );
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to get user reports',
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
        error: 'Failed to get user reports: ${e.toString()}',
      );
    }
  }

  // Get file size in human readable format
  String formatFileSize(int? bytes) {
    if (bytes == null || bytes == 0) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
