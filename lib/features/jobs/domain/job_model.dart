import 'package:cloud_firestore/cloud_firestore.dart';

class JobPost {
  JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.package,
    required this.experience,
    required this.requiredSkills,
    required this.immediateJoining,
    required this.description,
    required this.applyLink,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String package;
  final String experience;
  final List<String> requiredSkills;
  final bool immediateJoining;
  final String description;
  final String applyLink;
  final String createdBy;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'package': package,
      'experience': experience,
      'requiredSkills': requiredSkills,
      'immediateJoining': immediateJoining,
      'description': description,
      'applyLink': applyLink,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static JobPost fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final createdAtRaw = data['createdAt'];
    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return JobPost(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      company: (data['company'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      package: (data['package'] as String?) ?? '',
      experience: (data['experience'] as String?) ?? '',
      requiredSkills: ((data['requiredSkills'] as List?) ?? [])
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      immediateJoining: (data['immediateJoining'] as bool?) ?? false,
      description: (data['description'] as String?) ?? '',
      applyLink: (data['applyLink'] as String?) ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdAt: createdAt,
    );
  }
}
