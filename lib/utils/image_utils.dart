import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Utility class for image processing operations
class ImageUtils {
  /// Convert image file to base64 string
  static Future<String> imageToBase64(XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  /// Convert base64 string to image bytes
  static Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  /// Get image type from file or detect from bytes
  static String getImageTypeFromFile(XFile imageFile, Uint8List imageBytes) {
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
      extension = detectImageTypeFromBytes(imageBytes);
    }
    
    // Normalize common variations
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'jpeg';
      case 'png':
        return 'png';
      case 'gif':
        return 'gif';
      default:
        return extension.toLowerCase();
    }
  }

  /// Detect image type from file signature (magic bytes)
  static String detectImageTypeFromBytes(Uint8List bytes) {
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

  /// Validate image type
  static bool isValidImageType(String imageType) {
    return ['jpg', 'jpeg', 'png', 'gif'].contains(imageType.toLowerCase());
  }

  /// Validate image size (returns true if size is valid)
  static bool isValidImageSize(int sizeInBytes, {int maxSizeMB = 5}) {
    return sizeInBytes <= maxSizeMB * 1024 * 1024;
  }
}








