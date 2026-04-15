class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorDepartment;
  final String authorYear;
  final String authorType; // student or alumni
  final String category;
  final String title;
  final String content;
  final int views;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> likedBy;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorDepartment,
    required this.authorYear,
    required this.authorType,
    required this.category,
    required this.title,
    required this.content,
    this.views = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.likedBy = const [],
  });

  factory ForumPost.fromMap(Map<String, dynamic> map, String id) {
    return ForumPost(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorDepartment: map['authorDepartment'] ?? '',
      authorYear: map['authorYear'] ?? '',
      authorType: map['authorType'] ?? 'student',
      category: map['category'] ?? 'General',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      views: map['views'] ?? 0,
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorDepartment': authorDepartment,
      'authorYear': authorYear,
      'authorType': authorType,
      'category': category,
      'title': title,
      'content': content,
      'views': views,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'likedBy': likedBy,
    };
  }

  bool isLikedBy(String userId) {
    return likedBy.contains(userId);
  }
}

class ForumComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorType;
  final String content;
  final DateTime createdAt;
  final String? replyToId;
  final String? replyToName;

  ForumComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    required this.content,
    required this.createdAt,
    this.replyToId,
    this.replyToName,
  });

  factory ForumComment.fromMap(Map<String, dynamic> map, String id) {
    return ForumComment(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorType: map['authorType'] ?? 'student',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      replyToId: map['replyToId'],
      replyToName: map['replyToName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorType': authorType,
      'content': content,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'replyToId': replyToId,
      'replyToName': replyToName,
    };
  }
}

class ForumCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int postCount;
  final DateTime createdAt;

  ForumCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.postCount = 0,
    required this.createdAt,
  });

  factory ForumCategory.fromMap(Map<String, dynamic> map, String id) {
    return ForumCategory(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'forum',
      postCount: map['postCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'postCount': postCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
