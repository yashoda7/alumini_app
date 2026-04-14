class Resource {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type; // document, video, link, tutorial
  final String url;
  final String authorId;
  final String authorName;
  final String authorType;
  final int downloadCount;
  final int viewCount;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.url,
    required this.authorId,
    required this.authorName,
    required this.authorType,
    this.downloadCount = 0,
    this.viewCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory Resource.fromMap(Map<String, dynamic> map, String id) {
    return Resource(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      type: map['type'] ?? 'link',
      url: map['url'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorType: map['authorType'] ?? 'alumni',
      downloadCount: map['downloadCount'] ?? 0,
      viewCount: map['viewCount'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'url': url,
      'authorId': authorId,
      'authorName': authorName,
      'authorType': authorType,
      'downloadCount': downloadCount,
      'viewCount': viewCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }
}

class ResourceCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int resourceCount;
  final DateTime createdAt;

  ResourceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.resourceCount = 0,
    required this.createdAt,
  });

  factory ResourceCategory.fromMap(Map<String, dynamic> map, String id) {
    return ResourceCategory(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'folder',
      resourceCount: map['resourceCount'] ?? 0,
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
      'resourceCount': resourceCount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}

class ResourceReview {
  final String id;
  final String resourceId;
  final String reviewerId;
  final String reviewerName;
  final int rating; // 1-5
  final String comment;
  final DateTime createdAt;

  ResourceReview({
    required this.id,
    required this.resourceId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ResourceReview.fromMap(Map<String, dynamic> map, String id) {
    return ResourceReview(
      id: id,
      resourceId: map['resourceId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      rating: map['rating'] ?? 5,
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'resourceId': resourceId,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}
