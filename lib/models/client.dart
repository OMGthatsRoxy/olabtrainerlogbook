enum ClientStatus { active, inactive }

enum ClientGender { male, female, other }

enum FitnessGoal {
  weightLoss,
  muscleGain,
  endurance,
  flexibility,
  strength,
  general,
}

class Client {
  final String id;
  final String name;
  final String phone;
  final String email;
  final ClientGender gender;
  final int age;
  final double height; // cm
  final double weight; // kg
  final FitnessGoal fitnessGoal;
  final int courseCount;
  final double totalAmount;
  final DateTime startDate;
  final DateTime expiryDate;
  final DateTime joinDate;
  final ClientStatus status;
  final String notes;
  final String? avatar;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.courseCount,
    required this.totalAmount,
    required this.startDate,
    required this.expiryDate,
    required this.joinDate,
    required this.status,
    required this.notes,
    this.avatar,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      gender: ClientGender.values.firstWhere(
        (e) => e.toString() == 'ClientGender.${json['gender']}',
        orElse: () => ClientGender.other,
      ),
      age: json['age'] ?? 0,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      fitnessGoal: FitnessGoal.values.firstWhere(
        (e) => e.toString() == 'FitnessGoal.${json['fitnessGoal']}',
        orElse: () => FitnessGoal.general,
      ),
      courseCount: json['courseCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      joinDate: DateTime.parse(json['joinDate']),
      status: ClientStatus.values.firstWhere(
        (e) => e.toString() == 'ClientStatus.${json['status']}',
      ),
      notes: json['notes'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender.toString().split('.').last,
      'age': age,
      'height': height,
      'weight': weight,
      'fitnessGoal': fitnessGoal.toString().split('.').last,
      'courseCount': courseCount,
      'totalAmount': totalAmount,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'joinDate': joinDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'avatar': avatar,
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    ClientGender? gender,
    int? age,
    double? height,
    double? weight,
    FitnessGoal? fitnessGoal,
    int? courseCount,
    double? totalAmount,
    DateTime? startDate,
    DateTime? expiryDate,
    DateTime? joinDate,
    ClientStatus? status,
    String? notes,
    String? avatar,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      courseCount: courseCount ?? this.courseCount,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      avatar: avatar ?? this.avatar,
    );
  }
}
