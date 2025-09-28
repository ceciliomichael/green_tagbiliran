class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String targetType; // 'all' or 'barangay'
  final String? targetBarangay;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.targetType,
    this.targetBarangay,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      targetType: json['target_type'] as String,
      targetBarangay: json['target_barangay'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'target_type': targetType,
      'target_barangay': targetBarangay,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? targetType,
    String? targetBarangay,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      targetType: targetType ?? this.targetType,
      targetBarangay: targetBarangay ?? this.targetBarangay,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class NotificationStats {
  final int totalNotifications;
  final int totalRecipients;
  final int totalRead;
  final double readPercentage;
  final List<NotificationSummary> recentNotifications;

  NotificationStats({
    required this.totalNotifications,
    required this.totalRecipients,
    required this.totalRead,
    required this.readPercentage,
    required this.recentNotifications,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>;
    final recentList = json['recent_notifications'] as List<dynamic>? ?? [];

    return NotificationStats(
      totalNotifications: stats['total_notifications'] as int? ?? 0,
      totalRecipients: stats['total_recipients'] as int? ?? 0,
      totalRead: stats['total_read'] as int? ?? 0,
      readPercentage: (stats['read_percentage'] as num?)?.toDouble() ?? 0.0,
      recentNotifications: recentList
          .map(
            (item) =>
                NotificationSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class NotificationSummary {
  final String id;
  final String title;
  final String targetType;
  final String? targetBarangay;
  final int recipientsCount;
  final int readCount;
  final DateTime createdAt;

  NotificationSummary({
    required this.id,
    required this.title,
    required this.targetType,
    this.targetBarangay,
    required this.recipientsCount,
    required this.readCount,
    required this.createdAt,
  });

  factory NotificationSummary.fromJson(Map<String, dynamic> json) {
    return NotificationSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      targetType: json['target_type'] as String,
      targetBarangay: json['target_barangay'] as String?,
      recipientsCount: json['recipients_count'] as int? ?? 0,
      readCount: json['read_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  double get readPercentage {
    if (recipientsCount == 0) return 0.0;
    return (readCount / recipientsCount) * 100;
  }
}
