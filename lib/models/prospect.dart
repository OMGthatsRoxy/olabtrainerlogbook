enum ProspectSource { referral, online, walkIn, social }

enum ProspectStatus { contacted, interested, notInterested, converted }

enum ProspectGender { male, female, other }

enum ProspectFitnessGoal {
  weightLoss,
  muscleGain,
  endurance,
  flexibility,
  strength,
  general,
}

class Prospect {
  final String id;
  final String name;
  final String phone;
  final String email;
  final ProspectGender gender;
  final int age;
  final double height; // cm
  final double weight; // kg
  final ProspectFitnessGoal fitnessGoal;
  final ProspectSource source;
  final ProspectStatus status;
  final String notes;
  final DateTime contactDate;

  Prospect({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.source,
    required this.status,
    required this.notes,
    required this.contactDate,
  });

  factory Prospect.fromJson(Map<String, dynamic> json) {
    return Prospect(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      gender: ProspectGender.values.firstWhere(
        (e) => e.toString() == 'ProspectGender.${json['gender']}',
        orElse: () => ProspectGender.other,
      ),
      age: json['age'] ?? 0,
      height: (json['height'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      fitnessGoal: ProspectFitnessGoal.values.firstWhere(
        (e) => e.toString() == 'ProspectFitnessGoal.${json['fitnessGoal']}',
        orElse: () => ProspectFitnessGoal.general,
      ),
      source: ProspectSource.values.firstWhere(
        (e) => e.toString() == 'ProspectSource.${json['source']}',
      ),
      status: ProspectStatus.values.firstWhere(
        (e) => e.toString() == 'ProspectStatus.${json['status']}',
      ),
      notes: json['notes'],
      contactDate: DateTime.parse(json['contactDate']),
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
      'source': source.toString().split('.').last,
      'status': status.toString().split('.').last,
      'contactDate': contactDate.toIso8601String(),
      'notes': notes,
    };
  }

  Prospect copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    ProspectGender? gender,
    int? age,
    double? height,
    double? weight,
    ProspectFitnessGoal? fitnessGoal,
    ProspectSource? source,
    ProspectStatus? status,
    String? notes,
    DateTime? contactDate,
  }) {
    return Prospect(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      source: source ?? this.source,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      contactDate: contactDate ?? this.contactDate,
    );
  }
}
