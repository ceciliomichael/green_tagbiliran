class TruckDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String barangay;
  final String createdAt;

  TruckDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.barangay,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'; // Auto-generated as "Truck Driver for {barangay}"

  String get truckIdentifier => 'Truck $barangay 1';

  factory TruckDriver.fromJson(Map<String, dynamic> json) {
    return TruckDriver(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      barangay: json['barangay'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}

