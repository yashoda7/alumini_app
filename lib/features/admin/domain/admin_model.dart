class AdminStats {
  final int totalUsers;
  final int totalStudents;
  final int totalAlumni;
  final int totalJobs;
  final int totalEvents;
  final int totalAnnouncements;
  final int totalForumPosts;
  final int totalResources;
  final int totalMentorshipSlots;
  final int pendingReports;
  final DateTime lastUpdated;

  AdminStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalAlumni,
    required this.totalJobs,
    required this.totalEvents,
    required this.totalAnnouncements,
    required this.totalForumPosts,
    required this.totalResources,
    required this.totalMentorshipSlots,
    required this.pendingReports,
    required this.lastUpdated,
  });

  factory AdminStats.fromMap(Map<String, dynamic> map) {
    return AdminStats(
      totalUsers: map['totalUsers'] ?? 0,
      totalStudents: map['totalStudents'] ?? 0,
      totalAlumni: map['totalAlumni'] ?? 0,
      totalJobs: map['totalJobs'] ?? 0,
      totalEvents: map['totalEvents'] ?? 0,
      totalAnnouncements: map['totalAnnouncements'] ?? 0,
      totalForumPosts: map['totalForumPosts'] ?? 0,
      totalResources: map['totalResources'] ?? 0,
      totalMentorshipSlots: map['totalMentorshipSlots'] ?? 0,
      pendingReports: map['pendingReports'] ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'totalStudents': totalStudents,
      'totalAlumni': totalAlumni,
      'totalJobs': totalJobs,
      'totalEvents': totalEvents,
      'totalAnnouncements': totalAnnouncements,
      'totalForumPosts': totalForumPosts,
      'totalResources': totalResources,
      'totalMentorshipSlots': totalMentorshipSlots,
      'pendingReports': pendingReports,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

class ContentModerationItem {
  final String id;
  final String type; // job, event, announcement, forum_post, resource
  final String contentId;
  final String title;
  final String authorId;
  final String authorName;
  final String reportedBy;
  final String reason;
  final String status; // pending, reviewed, approved, rejected
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? adminNotes;

  ContentModerationItem({
    required this.id,
    required this.type,
    required this.contentId,
    required this.title,
    required this.authorId,
    required this.authorName,
    required this.reportedBy,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
    this.adminNotes,
  });

  factory ContentModerationItem.fromMap(Map<String, dynamic> map, String id) {
    return ContentModerationItem(
      id: id,
      type: map['type'] ?? 'post',
      contentId: map['contentId'] ?? '',
      title: map['title'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reviewedAt'])
          : null,
      adminNotes: map['adminNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'contentId': contentId,
      'title': title,
      'authorId': authorId,
      'authorName': authorName,
      'reportedBy': reportedBy,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
      'adminNotes': adminNotes,
    };
  }
}

class UserReport {
  final String id;
  final String reportedUserId;
  final String reportedUserName;
  final String reportedBy;
  final String reason;
  final String status; // pending, reviewed, action_taken, dismissed
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? actionTaken;

  UserReport({
    required this.id,
    required this.reportedUserId,
    required this.reportedUserName,
    required this.reportedBy,
    required this.reason,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
    this.actionTaken,
  });

  factory UserReport.fromMap(Map<String, dynamic> map, String id) {
    return UserReport(
      id: id,
      reportedUserId: map['reportedUserId'] ?? '',
      reportedUserName: map['reportedUserName'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['reviewedAt'])
          : null,
      actionTaken: map['actionTaken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportedUserId': reportedUserId,
      'reportedUserName': reportedUserName,
      'reportedBy': reportedBy,
      'reason': reason,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
      'actionTaken': actionTaken,
    };
  }
}
