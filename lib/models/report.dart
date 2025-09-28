enum ReportStatus { pending, inProgress, resolved, rejected }

class Report {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String barangay;
  final String issueDescription;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasImage;
  final bool hasAdminResponseImage;

  Report({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.barangay,
    required this.issueDescription,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.hasImage = false,
    this.hasAdminResponseImage = false,
  });

  // Create Report from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      barangay: json['barangay'] as String,
      issueDescription: json['issue_description'] as String,
      status: _parseReportStatus(json['status'] as String?),
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      hasImage: json['has_image'] as bool? ?? false,
      hasAdminResponseImage: json['has_admin_response_image'] as bool? ?? false,
    );
  }

  // Helper method to parse report status
  static ReportStatus _parseReportStatus(String? statusString) {
    switch (statusString) {
      case 'pending':
        return ReportStatus.pending;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }

  // Convert Report to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'barangay': barangay,
      'issue_description': issueDescription,
      'status': _reportStatusToString(status),
      'admin_notes': adminNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'has_image': hasImage,
      'has_admin_response_image': hasAdminResponseImage,
    };
  }

  // Helper method to convert report status to string
  String _reportStatusToString(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  // Get status display name
  String get statusDisplayName {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.rejected:
        return 'Rejected';
    }
  }

  // Create a copy of the report with updated fields
  Report copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? barangay,
    String? issueDescription,
    ReportStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasImage,
    bool? hasAdminResponseImage,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      barangay: barangay ?? this.barangay,
      issueDescription: issueDescription ?? this.issueDescription,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasImage: hasImage ?? this.hasImage,
      hasAdminResponseImage:
          hasAdminResponseImage ?? this.hasAdminResponseImage,
    );
  }

  @override
  String toString() {
    return 'Report{id: $id, fullName: $fullName, status: $statusDisplayName, barangay: $barangay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Report && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class ReportImage {
  final String id;
  final String reportId;
  final String imageData; // Base64 encoded image
  final String imageType;
  final int? fileSize;
  final DateTime createdAt;

  ReportImage({
    required this.id,
    required this.reportId,
    required this.imageData,
    required this.imageType,
    this.fileSize,
    required this.createdAt,
  });

  // Create ReportImage from JSON
  factory ReportImage.fromJson(Map<String, dynamic> json) {
    return ReportImage(
      id: json['id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      imageData: json['image_data']?.toString() ?? '',
      imageType: json['image_type']?.toString() ?? 'jpeg',
      fileSize: json['file_size'] as int?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  // Convert ReportImage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'image_data': imageData,
      'image_type': imageType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ReportImage{id: $id, reportId: $reportId, imageType: $imageType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportImage && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}

class AdminResponseImage {
  final String id;
  final String reportId;
  final String adminId;
  final String imageData; // Base64 encoded image
  final String imageType;
  final int? fileSize;
  final DateTime createdAt;
  final String? adminName;

  AdminResponseImage({
    required this.id,
    required this.reportId,
    required this.adminId,
    required this.imageData,
    required this.imageType,
    this.fileSize,
    required this.createdAt,
    this.adminName,
  });

  // Create AdminResponseImage from JSON
  factory AdminResponseImage.fromJson(Map<String, dynamic> json) {
    return AdminResponseImage(
      id: json['id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      imageData: json['image_data']?.toString() ?? '',
      imageType: json['image_type']?.toString() ?? 'jpeg',
      fileSize: json['file_size'] as int?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      adminName: json['admin_name']?.toString(),
    );
  }

  // Convert AdminResponseImage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'admin_id': adminId,
      'image_data': imageData,
      'image_type': imageType,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'admin_name': adminName,
    };
  }

  @override
  String toString() {
    return 'AdminResponseImage{id: $id, reportId: $reportId, adminId: $adminId, imageType: $imageType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminResponseImage && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
