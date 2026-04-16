import 'package:cloud_firestore/cloud_firestore.dart';

class Announcement {
  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String createdBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Announcement fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Announcement(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}
