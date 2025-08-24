enum UserRole { user, admin, truckDriver }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String barangay;
  final UserRole userRole;
  final DateTime createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.barangay,
    required this.userRole,
    required this.createdAt,
  });

  // Get full name
  String get fullName => '$firstName $lastName';

  // Create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      barangay: json['barangay'] as String,
      userRole: _parseUserRole(json['user_role'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Helper method to parse user role
  static UserRole _parseUserRole(String? roleString) {
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'truck_driver':
        return UserRole.truckDriver;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'barangay': barangay,
      'user_role': _userRoleToString(userRole),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to convert user role to string
  String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.truckDriver:
        return 'truck_driver';
      case UserRole.user:
        return 'user';
    }
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? barangay,
    UserRole? userRole,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      barangay: barangay ?? this.barangay,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, phone: $phone, barangay: $barangay}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
