class UserProfile {
  final String uid;
  final String displayName;
  final String? phone;
  final String? introduction;
  final List<String> specialties;
  final int experienceYears;
  final String? certificates;
  final String? education;
  final String? location;
  final bool isPublicProfile;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.phone,
    this.introduction,
    required this.specialties,
    required this.experienceYears,
    this.certificates,
    this.education,
    this.location,
    required this.isPublicProfile,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      phone: json['phone'],
      introduction: json['introduction'],
      specialties: List<String>.from(json['specialties'] ?? []),
      experienceYears: json['experienceYears'] ?? 0,
      certificates: json['certificates'],
      education: json['education'],
      location: json['location'],
      isPublicProfile: json['isPublicProfile'] ?? true,
      photoURL: json['photoURL'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'phone': phone,
      'introduction': introduction,
      'specialties': specialties,
      'experienceYears': experienceYears,
      'certificates': certificates,
      'education': education,
      'location': location,
      'isPublicProfile': isPublicProfile,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? phone,
    String? introduction,
    List<String>? specialties,
    int? experienceYears,
    String? certificates,
    String? education,
    String? location,
    bool? isPublicProfile,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      introduction: introduction ?? this.introduction,
      specialties: specialties ?? this.specialties,
      experienceYears: experienceYears ?? this.experienceYears,
      certificates: certificates ?? this.certificates,
      education: education ?? this.education,
      location: location ?? this.location,
      isPublicProfile: isPublicProfile ?? this.isPublicProfile,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
