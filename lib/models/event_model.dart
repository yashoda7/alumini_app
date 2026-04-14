import 'package:cloud_firestore/cloud_firestore.dart';

class AppEvent {
  AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.eventLink,
    required this.eventDate,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final String eventLink;
  final DateTime eventDate;
  final String createdBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'eventLink': eventLink,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static AppEvent fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    DateTime _asDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return AppEvent(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      eventLink: (data['eventLink'] as String?) ?? '',
      eventDate: _asDate(data['eventDate']),
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: _asDate(data['createdAt']),
    );
  }
}
