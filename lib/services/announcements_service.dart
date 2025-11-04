import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/announcement.dart';
import '../constants/supabase_config.dart';
import '../utils/image_utils.dart';

class AnnouncementResult {
  final bool success;
  final String? error;
  final Announcement? announcement;
  final List<Announcement>? announcements;
  final String? message;

  AnnouncementResult({
    required this.success,
    this.error,
    this.announcement,
    this.announcements,
    this.message,
  });
}

class AnnouncementsService {
  static final AnnouncementsService _instance = AnnouncementsService._internal();
  factory AnnouncementsService() => _instance;
  AnnouncementsService._internal();

  /// Create new announcement with optional image
  Future<AnnouncementResult> createAnnouncement({
    required String title,
    required String description,
    required String createdBy,
    XFile? imageFile,
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty || description.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'Title and description are required',
        );
      }

      if (createdBy.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'User authentication required',
        );
      }

      // Process image if provided
      String? imageBase64;
      String? imageType;
      if (imageFile != null) {
        try {
          final imageDataList =
              await ImageUtils.processImagesForUpload([imageFile]);
          if (imageDataList.isNotEmpty) {
            imageBase64 = imageDataList[0]['image_data'] as String;
            imageType = imageDataList[0]['image_type'] as String;
          }
        } catch (e) {
          return AnnouncementResult(
            success: false,
            error: e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }

      // Prepare request body
      final requestBody = {
        'p_title': title.trim(),
        'p_description': description.trim(),
        'p_created_by': createdBy,
        'p_image_data': imageBase64,
        'p_image_type': imageType,
      };

      // Make HTTP request to create announcement function
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/create_announcement'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final announcementData = responseData['announcement'];
          final announcement = Announcement.fromJson(announcementData);

          return AnnouncementResult(
            success: true,
            announcement: announcement,
            message: responseData['message'] ?? 'Announcement created successfully',
          );
        } else {
          return AnnouncementResult(
            success: false,
            error: responseData['error'] ?? 'Failed to create announcement',
          );
        }
      } else {
        return AnnouncementResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AnnouncementResult(
        success: false,
        error: 'Failed to create announcement: ${e.toString()}',
      );
    }
  }

  /// Get all announcements
  Future<AnnouncementResult> getAllAnnouncements() async {
    try {
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/get_all_announcements'),
        headers: SupabaseConfig.headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final announcementsData = responseData['announcements'] as List;
          final announcements = announcementsData
              .map((data) => Announcement.fromJson(data))
              .toList();

          return AnnouncementResult(
            success: true,
            announcements: announcements,
          );
        } else {
          return AnnouncementResult(
            success: false,
            error: responseData['error'] ?? 'Failed to fetch announcements',
          );
        }
      } else {
        return AnnouncementResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AnnouncementResult(
        success: false,
        error: 'Failed to fetch announcements: ${e.toString()}',
      );
    }
  }

  /// Get announcements by admin user
  Future<AnnouncementResult> getAnnouncementsByAdmin(String adminId) async {
    try {
      if (adminId.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'Admin ID is required',
        );
      }

      final requestBody = {'p_admin_id': adminId};

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/get_announcements_by_admin'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final announcementsData = responseData['announcements'] as List;
          final announcements = announcementsData
              .map((data) => Announcement.fromJson(data))
              .toList();

          return AnnouncementResult(
            success: true,
            announcements: announcements,
          );
        } else {
          return AnnouncementResult(
            success: false,
            error: responseData['error'] ?? 'Failed to fetch announcements',
          );
        }
      } else {
        return AnnouncementResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AnnouncementResult(
        success: false,
        error: 'Failed to fetch announcements: ${e.toString()}',
      );
    }
  }

  /// Update announcement with optional image
  Future<AnnouncementResult> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
    required String userId,
    XFile? imageFile,
    bool removeImage = false,
  }) async {
    try {
      // Validate input
      if (title.trim().isEmpty || description.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'Title and description are required',
        );
      }

      if (announcementId.trim().isEmpty || userId.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'Invalid announcement or user ID',
        );
      }

      // Process image if provided
      String? imageBase64;
      String? imageType;
      if (imageFile != null && !removeImage) {
        try {
          final imageDataList =
              await ImageUtils.processImagesForUpload([imageFile]);
          if (imageDataList.isNotEmpty) {
            imageBase64 = imageDataList[0]['image_data'] as String;
            imageType = imageDataList[0]['image_type'] as String;
          }
        } catch (e) {
          return AnnouncementResult(
            success: false,
            error: e.toString().replaceFirst('Exception: ', ''),
          );
        }
      }

      // Prepare request body
      final requestBody = {
        'p_announcement_id': announcementId,
        'p_title': title.trim(),
        'p_description': description.trim(),
        'p_user_id': userId,
        'p_image_data': imageBase64,
        'p_image_type': imageType,
        'p_remove_image': removeImage,
      };

      // Make HTTP request to update announcement function
      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/update_announcement'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final announcementData = responseData['announcement'];
          final announcement = Announcement.fromJson(announcementData);

          return AnnouncementResult(
            success: true,
            announcement: announcement,
            message: responseData['message'] ?? 'Announcement updated successfully',
          );
        } else {
          return AnnouncementResult(
            success: false,
            error: responseData['error'] ?? 'Failed to update announcement',
          );
        }
      } else {
        return AnnouncementResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AnnouncementResult(
        success: false,
        error: 'Failed to update announcement: ${e.toString()}',
      );
    }
  }

  /// Delete announcement
  Future<AnnouncementResult> deleteAnnouncement({
    required String announcementId,
    required String userId,
  }) async {
    try {
      if (announcementId.trim().isEmpty || userId.trim().isEmpty) {
        return AnnouncementResult(
          success: false,
          error: 'Invalid announcement or user ID',
        );
      }

      final requestBody = {
        'p_announcement_id': announcementId,
        'p_user_id': userId,
      };

      final response = await http.post(
        Uri.parse('${SupabaseConfig.baseApiUrl}/delete_announcement'),
        headers: SupabaseConfig.headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return AnnouncementResult(
            success: true,
            message: responseData['message'] ?? 'Announcement deleted successfully',
          );
        } else {
          return AnnouncementResult(
            success: false,
            error: responseData['error'] ?? 'Failed to delete announcement',
          );
        }
      } else {
        return AnnouncementResult(
          success: false,
          error: 'Network error: ${response.statusCode}',
        );
      }
    } catch (e) {
      return AnnouncementResult(
        success: false,
        error: 'Failed to delete announcement: ${e.toString()}',
      );
    }
  }
}
