class MentorshipSlot {
  final String id;
  final String mentorId;
  final String mentorName;
  final String mentorDepartment;
  final String mentorCompany;
  final String mentorYear;
  final String expertise;
  final String description;
  final int maxMentees;
  final int currentMentees;
  final DateTime createdAt;
  final bool isActive;

  MentorshipSlot({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.mentorDepartment,
    required this.mentorCompany,
    required this.mentorYear,
    required this.expertise,
    required this.description,
    required this.maxMentees,
    this.currentMentees = 0,
    required this.createdAt,
    this.isActive = true,
  });

  factory MentorshipSlot.fromMap(Map<String, dynamic> map, String id) {
    return MentorshipSlot(
      id: id,
      mentorId: map['mentorId'] ?? '',
      mentorName: map['mentorName'] ?? '',
      mentorDepartment: map['mentorDepartment'] ?? '',
      mentorCompany: map['mentorCompany'] ?? '',
      mentorYear: map['mentorYear'] ?? '',
      expertise: map['expertise'] ?? '',
      description: map['description'] ?? '',
      maxMentees: map['maxMentees'] ?? 5,
      currentMentees: map['currentMentees'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'mentorName': mentorName,
      'mentorDepartment': mentorDepartment,
      'mentorCompany': mentorCompany,
      'mentorYear': mentorYear,
      'expertise': expertise,
      'description': description,
      'maxMentees': maxMentees,
      'currentMentees': currentMentees,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }
}

class MentorshipRequest {
  final String id;
  final String slotId;
  final String mentorId;
  final String menteeId;
  final String menteeName;
  final String menteeDepartment;
  final String menteeYear;
  final String message;
  final String status; // pending, accepted, rejected, completed
  final DateTime createdAt;
  final DateTime? respondedAt;

  MentorshipRequest({
    required this.id,
    required this.slotId,
    required this.mentorId,
    required this.menteeId,
    required this.menteeName,
    required this.menteeDepartment,
    required this.menteeYear,
    required this.message,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
  });

  factory MentorshipRequest.fromMap(Map<String, dynamic> map, String id) {
    return MentorshipRequest(
      id: id,
      slotId: map['slotId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      menteeId: map['menteeId'] ?? '',
      menteeName: map['menteeName'] ?? '',
      menteeDepartment: map['menteeDepartment'] ?? '',
      menteeYear: map['menteeYear'] ?? '',
      message: map['message'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      respondedAt: map['respondedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'slotId': slotId,
      'mentorId': mentorId,
      'menteeId': menteeId,
      'menteeName': menteeName,
      'menteeDepartment': menteeDepartment,
      'menteeYear': menteeYear,
      'message': message,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'respondedAt': respondedAt?.millisecondsSinceEpoch,
    };
  }
}

class MentorshipSession {
  final String id;
  final String requestId;
  final String slotId;
  final String mentorId;
  final String menteeId;
  final String topic;
  final DateTime scheduledAt;
  final String notes;
  final String status; // scheduled, completed, cancelled
  final DateTime createdAt;

  MentorshipSession({
    required this.id,
    required this.requestId,
    required this.slotId,
    required this.mentorId,
    required this.menteeId,
    required this.topic,
    required this.scheduledAt,
    this.notes = '',
    this.status = 'scheduled',
    required this.createdAt,
  });

  factory MentorshipSession.fromMap(Map<String, dynamic> map, String id) {
    return MentorshipSession(
      id: id,
      requestId: map['requestId'] ?? '',
      slotId: map['slotId'] ?? '',
      mentorId: map['mentorId'] ?? '',
      menteeId: map['menteeId'] ?? '',
      topic: map['topic'] ?? '',
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['scheduledAt'])
          : DateTime.now(),
      notes: map['notes'] ?? '',
      status: map['status'] ?? 'scheduled',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'slotId': slotId,
      'mentorId': mentorId,
      'menteeId': menteeId,
      'topic': topic,
      'scheduledAt': scheduledAt.millisecondsSinceEpoch,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
