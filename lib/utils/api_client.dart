import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Generic result wrapper for API responses
class ApiResult<T> {
  final bool success;
  final String? error;
  final T? data;
  final String? message;

  ApiResult({
    required this.success,
    this.error,
    this.data,
    this.message,
  });
}

/// HTTP client wrapper to eliminate duplicate response handling
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// Generic HTTP POST call with standardized error handling
  Future<ApiResult<Map<String, dynamic>>> post({
    required String endpoint,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseData['success'] == true) {
          return ApiResult<Map<String, dynamic>>(
            success: true,
            data: responseData,
            message: responseData['message'] as String?,
          );
        } else {
          return ApiResult<Map<String, dynamic>>(
            success: false,
            error: responseData['error'] as String? ?? 'Request failed',
          );
        }
      } else {
        return ApiResult<Map<String, dynamic>>(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      return ApiResult<Map<String, dynamic>>(
        success: false,
        error: 'Request timed out',
      );
    } catch (e) {
      return ApiResult<Map<String, dynamic>>(
        success: false,
        error: 'Request failed: ${e.toString()}',
      );
    }
  }
}

