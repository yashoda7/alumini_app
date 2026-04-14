import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.userType,
    required this.department,
    required this.year,
    required this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final String userType;
  final String department;
  final String year;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'userType': userType,
      'department': department,
      'year': year,
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
      userType: (data['userType'] as String?) ?? 'student',
      department: (data['department'] as String?) ?? '',
      year: (data['year'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}
