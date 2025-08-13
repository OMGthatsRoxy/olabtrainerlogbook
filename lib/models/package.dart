enum PackageStatus { active, completed, expired }

class Package {
  final String id;
  final String clientId;
  final int totalHours;
  final double totalAmount;
  final int remainingSessions;
  final DateTime startDate;
  final DateTime expiryDate;
  final PackageStatus status;
  final String notes;
  final DateTime createdAt;

  Package({
    required this.id,
    required this.clientId,
    required this.totalHours,
    required this.totalAmount,
    required this.remainingSessions,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      clientId: json['clientId'],
      totalHours: json['totalHours'],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      remainingSessions: json['remainingSessions'],
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      status: PackageStatus.values.firstWhere(
        (e) => e.toString() == 'PackageStatus.${json['status']}',
        orElse: () => PackageStatus.active,
      ),
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'totalHours': totalHours,
      'totalAmount': totalAmount,
      'remainingSessions': remainingSessions,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Package copyWith({
    String? id,
    String? clientId,
    int? totalHours,
    double? totalAmount,
    int? remainingSessions,
    DateTime? startDate,
    DateTime? expiryDate,
    PackageStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Package(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      totalHours: totalHours ?? this.totalHours,
      totalAmount: totalAmount ?? this.totalAmount,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
