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
      isProfileComplete: (data['isProfileComplete'] as bool?) ?? false,
      createdAt: createdAt,
    );
  }
}
