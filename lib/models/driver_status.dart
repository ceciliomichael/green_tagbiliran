/// Driver status enumeration for tracking collection progress
/// Each status represents a specific street/location in the Cogon collection route
enum DriverStatus {
  // Starting point (0)
  notStarted('not_started', 'Starting Point', 'Starting Point', 0),
  
  // Northern Cogon (1-5)
  cpGarciaAvenue('cp_garcia_avenue', 'C.P. Garcia Avenue', 'Northern Cogon', 1),
  calcetaStreet('calceta_street', 'Calceta Street', 'Northern Cogon', 2),
  hangosStreet('hangos_street', 'Hangos Street', 'Northern Cogon', 3),
  torralbaStreet('torralba_street', 'F. Torralba Street', 'Northern Cogon', 4),
  
  // Central Cogon (5-8)
  intingStreet('inting_street', 'B. Inting Street', 'Central Cogon', 5),
  parrasStreet('parras_street', 'Mariano Parras Street', 'Central Cogon', 6),
  enerioStreet('enerio_street', 'Enerio Street', 'Central Cogon', 7),
  rochaStreet('rocha_street', 'F. Rocha Street', 'Central Cogon', 8),
  
  // South Cogon (9-12)
  tamblotStreet('tamblot_street', 'Tamblot Street', 'South Cogon', 9),
  borjaStreet('borja_street', 'J. Borja Street', 'South Cogon', 10),
  palmaStreet('palma_street', 'Palma Street', 'South Cogon', 11),
  putongStreet('putong_street', 'C. Putong Street', 'South Cogon', 12),
  
  // West Cogon (13-15)
  gallaresStreet('gallares_street', 'Celestino Gallares Street', 'West Cogon', 13),
  cogonMarket('cogon_market', 'Cogon Market', 'West Cogon', 14),
  pamaongStreet('pamaong_street', 'Pamaong Street', 'West Cogon', 15),
  
  // Final Sweep (16-17)
  metrobankCogon('metrobank_cogon', 'Metrobank Cogon', 'Final Sweep', 16),
  busTerminal('bus_terminal', 'Cogon Bus Terminal', 'Final Sweep', 17),
  
  // Completed (18)
  completed('completed', 'Collection Complete', 'Completed', 18);

  final String value;
  final String displayName;
  final String zone;
  final int order;
  
  const DriverStatus(this.value, this.displayName, this.zone, this.order);

  /// Convert from string value to enum
  static DriverStatus fromString(String value) {
    return DriverStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => DriverStatus.notStarted,
    );
  }

  /// Get the next status in the progression
  DriverStatus? get next {
    if (this == DriverStatus.completed) return null;
    final currentIndex = DriverStatus.values.indexOf(this);
    if (currentIndex < DriverStatus.values.length - 1) {
      return DriverStatus.values[currentIndex + 1];
    }
    return null;
  }

  /// Check if this is the final status
  bool get isCompleted => this == DriverStatus.completed;

  /// Get progress percentage (0-100)
  int get progressPercentage {
    return ((order / 18) * 100).round();
  }
  
  /// Get button label for driver interface
  String get buttonLabel {
    if (this == DriverStatus.notStarted) {
      return 'Start Collection';
    } else if (this == DriverStatus.completed) {
      return 'Collection Complete';
    } else {
      return 'At $displayName';
    }
  }
}

/// Driver status record model
class DriverStatusRecord {
  final String id;
  final String driverId;
  final String barangay;
  final DriverStatus status;
  final String? statusMessage;
  final String? driverName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverStatusRecord({
    required this.id,
    required this.driverId,
    required this.barangay,
    required this.status,
    this.statusMessage,
    this.driverName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON response
  factory DriverStatusRecord.fromJson(Map<String, dynamic> json) {
    return DriverStatusRecord(
      id: json['id'] as String,
      driverId: json['driver_id'] as String,
      barangay: json['barangay'] as String,
      status: DriverStatus.fromString(json['status'] as String),
      statusMessage: json['status_message'] as String?,
      driverName: json['driver_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver_id': driverId,
      'barangay': barangay,
      'status': status.value,
      'status_message': statusMessage,
      'driver_name': driverName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get time since last update in human-readable format
  String getTimeSinceUpdate() {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Check if status is stale (older than 30 minutes)
  bool get isStale {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);
    return difference.inMinutes > 30;
  }

  /// Copy with method for immutability
  DriverStatusRecord copyWith({
    String? id,
    String? driverId,
    String? barangay,
    DriverStatus? status,
    String? statusMessage,
    String? driverName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverStatusRecord(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      barangay: barangay ?? this.barangay,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
      driverName: driverName ?? this.driverName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

