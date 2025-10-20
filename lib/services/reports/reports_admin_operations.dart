part of '../reports_service.dart';

extension ReportsAdminOperations on ReportsService {
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

  // Update report status with admin response images (admin only)
  Future<ReportsResult> updateReportStatusWithImages({
    required String adminId,
    required String reportId,
    required String status,
    String? adminNotes,
    List<XFile>? images,
    String? adminName,
  }) async {
    try {
      List<Map<String, dynamic>> imageDataList = [];

      // Convert images to base64 if provided
      if (images != null && images.isNotEmpty) {
        for (final image in images) {
          final bytes = await image.readAsBytes();
          final imageData = base64Encode(bytes);
          final imageType = getImageType(image.path);
          final fileSize = bytes.length;

          imageDataList.add({
            'image_data': imageData,
            'image_type': imageType,
            'file_size': fileSize,
          });
        }
      }

      final requestBody = {
        'p_admin_id': adminId,
        'p_report_id': reportId,
        'p_status': status,
        if (adminNotes != null) 'p_admin_notes': adminNotes,
        if (imageDataList.isNotEmpty) 'p_images': imageDataList,
        if (adminName != null && adminName.trim().isNotEmpty)
          'p_admin_name': adminName.trim(),
      };

      final response = await http.post(
        Uri.parse(SupabaseConfig.updateReportStatusWithImagesEndpoint),
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

  // Delete report (admin only)
  Future<ReportsResult> deleteReport({
    required String adminId,
    required String reportId,
  }) async {
    try {
      final requestBody = {
        'p_admin_id': adminId,
        'p_report_id': reportId,
      };

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/delete_report'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return ReportsResult(
            success: true,
            message: responseData['message'] ?? 'Report deleted successfully',
          );
        } else {
          return ReportsResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete report',
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
        error: 'Failed to delete report: ${e.toString()}',
      );
    }
  }
}

