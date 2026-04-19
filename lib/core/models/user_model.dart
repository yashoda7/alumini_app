import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.userType,
    this.department,
    this.year,
    this.areaOfInterest,
    this.presentTechnologies,
    this.yearsOfExperience,
    this.isProfileComplete = false,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  /// Nullable until the user completes the profile onboarding.
  final String? userType;
  final String? department;
  final String? year;
  final String? areaOfInterest;
  final String? presentTechnologies;
  final String? yearsOfExperience;

  /// false  → route to ProfileCompletionScreen
  /// true   → route to role-specific home screen
  final bool isProfileComplete;
  final DateTime createdAt;

  // ── Convenience getters ─────────────────────────────────────────────
  bool get isAlumni => userType == 'alumni';
  bool get isAdmin => userType == 'admin';

  // ── Partial update helper ───────────────────────────────────────────
  AppUser copyWith({
    String? name,
    String? photoUrl,
    String? userType,
    String? department,
    String? year,
    String? areaOfInterest,
    String? presentTechnologies,
    String? yearsOfExperience,
    bool? isProfileComplete,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      createdAt: createdAt,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      userType: userType ?? this.userType,
      department: department ?? this.department,
      year: year ?? this.year,
      areaOfInterest: areaOfInterest ?? this.areaOfInterest,
      presentTechnologies: presentTechnologies ?? this.presentTechnologies,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'userType': userType,
      'department': department,
      'year': year,
      'areaOfInterest': areaOfInterest,
      'presentTechnologies': presentTechnologies,
      'yearsOfExperience': yearsOfExperience,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static AppUser fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw StateError('User document is empty');
    }

    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return AppUser(
      uid: (data['uid'] as String?) ?? doc.id,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      photoUrl: data['photoUrl'] as String?,
      userType: data['userType'] as String?,
      department: data['department'] as String?,
      year: data['year'] as String?,
      areaOfInterest: data['areaOfInterest'] as String?,
      presentTechnologies: data['presentTechnologies'] as String?,
      yearsOfExperience: data['yearsOfExperience'] as String?,
      isProfileComplete: (data['isProfileComplete'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }
}
