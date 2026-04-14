class AnalyticsData {
  final String id;
  final String contentId;
  final String contentType; // job, event, announcement, forum_post, resource
  final String authorId;
  final int views;
  final int clicks;
  final int applicants;
  final int attendees;
  final int likes;
  final int shares;
  final DateTime date;
  final Map<String, dynamic> metadata;

  AnalyticsData({
    required this.id,
    required this.contentId,
    required this.contentType,
    required this.authorId,
    this.views = 0,
    this.clicks = 0,
    this.applicants = 0,
    this.attendees = 0,
    this.likes = 0,
    this.shares = 0,
    required this.date,
    this.metadata = const {},
  });

  factory AnalyticsData.fromMap(Map<String, dynamic> map, String id) {
    return AnalyticsData(
      id: id,
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? 'post',
      authorId: map['authorId'] ?? '',
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      applicants: map['applicants'] ?? 0,
      attendees: map['attendees'] ?? 0,
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'authorId': authorId,
      'views': views,
      'clicks': clicks,
      'applicants': applicants,
      'attendees': attendees,
      'likes': likes,
      'shares': shares,
      'date': date.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }
}

class EngagementMetrics {
  final String userId;
  final String userName;
  final String userType;
  final int postsCreated;
  final int commentsMade;
  final int likesGiven;
  final int resourcesShared;
  final int mentorshipSessions;
  final int eventsAttended;
  final DateTime lastActive;
  final double engagementScore;

  EngagementMetrics({
    required this.userId,
    required this.userName,
    required this.userType,
    this.postsCreated = 0,
    this.commentsMade = 0,
    this.likesGiven = 0,
    this.resourcesShared = 0,
    this.mentorshipSessions = 0,
    this.eventsAttended = 0,
    required this.lastActive,
    this.engagementScore = 0.0,
  });

  factory EngagementMetrics.fromMap(Map<String, dynamic> map) {
    return EngagementMetrics(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userType: map['userType'] ?? 'student',
      postsCreated: map['postsCreated'] ?? 0,
      commentsMade: map['commentsMade'] ?? 0,
      likesGiven: map['likesGiven'] ?? 0,
      resourcesShared: map['resourcesShared'] ?? 0,
      mentorshipSessions: map['mentorshipSessions'] ?? 0,
      eventsAttended: map['eventsAttended'] ?? 0,
      lastActive: map['lastActive'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastActive'])
          : DateTime.now(),
      engagementScore: (map['engagementScore'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'postsCreated': postsCreated,
      'commentsMade': commentsMade,
      'likesGiven': likesGiven,
      'resourcesShared': resourcesShared,
      'mentorshipSessions': mentorshipSessions,
      'eventsAttended': eventsAttended,
      'lastActive': lastActive.millisecondsSinceEpoch,
      'engagementScore': engagementScore,
    };
  }
}

class PostAnalytics {
  final String contentId;
  final String contentType;
  final String title;
  final int totalViews;
  final int uniqueViews;
  final int totalClicks;
  final int conversionRate;
  final List<DailyStats> dailyStats;
  final DateTime createdAt;
  final DateTime lastUpdated;

  PostAnalytics({
    required this.contentId,
    required this.contentType,
    required this.title,
    this.totalViews = 0,
    this.uniqueViews = 0,
    this.totalClicks = 0,
    this.conversionRate = 0,
    this.dailyStats = const [],
    required this.createdAt,
    required this.lastUpdated,
  });

  factory PostAnalytics.fromMap(Map<String, dynamic> map) {
    return PostAnalytics(
      contentId: map['contentId'] ?? '',
      contentType: map['contentType'] ?? 'post',
      title: map['title'] ?? '',
      totalViews: map['totalViews'] ?? 0,
      uniqueViews: map['uniqueViews'] ?? 0,
      totalClicks: map['totalClicks'] ?? 0,
      conversionRate: map['conversionRate'] ?? 0,
      dailyStats: (map['dailyStats'] as List?)
              ?.map((e) => DailyStats.fromMap(e))
              .toList() ??
          [],
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'title': title,
      'totalViews': totalViews,
      'uniqueViews': uniqueViews,
      'totalClicks': totalClicks,
      'conversionRate': conversionRate,
      'dailyStats': dailyStats.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }
}

class DailyStats {
  final DateTime date;
  final int views;
  final int clicks;
  final int engagements;

  DailyStats({
    required this.date,
    this.views = 0,
    this.clicks = 0,
    this.engagements = 0,
  });

  factory DailyStats.fromMap(Map<String, dynamic> map) {
    return DailyStats(
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : DateTime.now(),
      views: map['views'] ?? 0,
      clicks: map['clicks'] ?? 0,
      engagements: map['engagements'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'views': views,
      'clicks': clicks,
      'engagements': engagements,
    };
  }
}
