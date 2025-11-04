part of '../reports_service.dart';

extension ReportsUserOperations on ReportsService {
  // Submit a report with optional images (up to 3)
  Future<ReportsResult> submitReport({
    required User user,
    required String fullName,
    required String phone,
    required String barangay,
    required String issueDescription,
    List<XFile>? images,
  }) async {
    try {
      List<Map<String, dynamic>> imageDataList = [];

      // Convert images to base64 if provided
      if (images != null && images.isNotEmpty) {
        imageDataList = await ImageUtils.processImagesForUpload(images);
      }

      // Prepare request body
      final requestBody = {
        'p_user_id': user.id,
        'p_full_name': fullName,
        'p_phone': phone,
        'p_barangay': barangay,
        'p_issue_description': issueDescription,
        if (imageDataList.isNotEmpty) 'p_images': imageDataList,
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
}

