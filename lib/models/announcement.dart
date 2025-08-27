class Announcement {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create Announcement from JSON
  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      createdBy: json['created_by'] as String,
      createdByName: json['created_by_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert Announcement to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy of the announcement with updated fields
  Announcement copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if announcement has image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  // Format created date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'Announcement{id: $id, title: $title, createdBy: $createdByName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Announcement && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
