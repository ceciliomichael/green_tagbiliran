import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/announcement.dart';
import '../constants/supabase_config.dart';

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

  // Create new announcement
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
        final imageBytes = await imageFile.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
        
        // Get file type from XFile properties or detect from bytes
        imageType = _getImageTypeFromFile(imageFile, imageBytes);
        
        // Validate image type
        if (!['jpg', 'jpeg', 'png', 'gif'].contains(imageType)) {
          return AnnouncementResult(
            success: false,
            error: 'Only JPG, JPEG, PNG, and GIF images are allowed. Detected: $imageType',
          );
        }

        // Validate image size (max 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          return AnnouncementResult(
            success: false,
            error: 'Image size must be less than 5MB',
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

  // Get all announcements
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

  // Get announcements by admin user
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

  // Update announcement
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
        final imageBytes = await imageFile.readAsBytes();
        imageBase64 = base64Encode(imageBytes);
        
        // Get file type from XFile properties or detect from bytes
        imageType = _getImageTypeFromFile(imageFile, imageBytes);
        
        // Validate image type
        if (!['jpg', 'jpeg', 'png', 'gif'].contains(imageType)) {
          return AnnouncementResult(
            success: false,
            error: 'Only JPG, JPEG, PNG, and GIF images are allowed. Detected: $imageType',
          );
        }

        // Validate image size (max 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          return AnnouncementResult(
            success: false,
            error: 'Image size must be less than 5MB',
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

  // Delete announcement
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

  // Convert image file to base64
  Future<String> imageToBase64(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  // Convert base64 to image bytes
  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  // Helper method to detect image type from file or bytes
  String _getImageTypeFromFile(XFile imageFile, Uint8List imageBytes) {
    // First try to get from file name/path
    String? extension;
    if (imageFile.name.isNotEmpty) {
      final nameParts = imageFile.name.split('.');
      if (nameParts.length > 1) {
        extension = nameParts.last.toLowerCase();
      }
    }
    
    // If no extension from name, try from path
    if (extension == null || extension.isEmpty) {
      final pathParts = imageFile.path.split('.');
      if (pathParts.length > 1) {
        extension = pathParts.last.toLowerCase();
      }
    }
    
    // If still no extension, try to detect from file signature (magic bytes)
    if (extension == null || extension.isEmpty) {
      extension = _detectImageTypeFromBytes(imageBytes);
    }
    
    // Normalize common variations
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return extension?.toLowerCase() ?? 'unknown';
    }
  }

  // Detect image type from file signature (magic bytes)
  String _detectImageTypeFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return 'unknown';
    
    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpeg';
    }
    
    // PNG: 89 50 4E 47
    if (bytes.length >= 8 && 
        bytes[0] == 0x89 && bytes[1] == 0x50 && 
        bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'png';
    }
    
    // GIF: 47 49 46 38 (GIF8)
    if (bytes.length >= 6 && 
        bytes[0] == 0x47 && bytes[1] == 0x49 && 
        bytes[2] == 0x46 && bytes[3] == 0x38) {
      return 'gif';
    }
    
    return 'unknown';
  }
}
