import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/models/user_model.dart';
import '../features/admin/domain/admin_model.dart';
import '../features/analytics/domain/analytics_model.dart';
import '../features/announcements/domain/announcement_model.dart';
import '../features/chat/domain/chat_message_model.dart';
import '../features/chat/domain/chat_thread_model.dart';
import '../features/events/domain/event_model.dart';
import '../features/forum/domain/forum_model.dart';
import '../features/jobs/domain/job_model.dart';
import '../features/mentorship/domain/mentorship_model.dart';
import '../features/resources/domain/resource_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _jobs =>
      _firestore.collection('jobs');

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _firestore.collection('announcements');

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> get _mentorshipSlots =>
      _firestore.collection('mentorship_slots');

  CollectionReference<Map<String, dynamic>> get _mentorshipRequests =>
      _firestore.collection('mentorship_requests');

  CollectionReference<Map<String, dynamic>> get _mentorshipSessions =>
      _firestore.collection('mentorship_sessions');

  CollectionReference<Map<String, dynamic>> get _forumPosts =>
      _firestore.collection('forum_posts');

  CollectionReference<Map<String, dynamic>> get _forumComments =>
      _firestore.collection('forum_comments');

  CollectionReference<Map<String, dynamic>> get _forumCategories =>
      _firestore.collection('forum_categories');

  CollectionReference<Map<String, dynamic>> get _resources =>
      _firestore.collection('resources');

  CollectionReference<Map<String, dynamic>> get _resourceCategories =>
      _firestore.collection('resource_categories');

  CollectionReference<Map<String, dynamic>> get _resourceReviews =>
      _firestore.collection('resource_reviews');

  CollectionReference<Map<String, dynamic>> get _adminStats =>
      _firestore.collection('admin_stats');

  CollectionReference<Map<String, dynamic>> get _contentModeration =>
      _firestore.collection('content_moderation');

  CollectionReference<Map<String, dynamic>> get _userReports =>
      _firestore.collection('user_reports');

  CollectionReference<Map<String, dynamic>> get _analytics =>
      _firestore.collection('analytics');

  CollectionReference<Map<String, dynamic>> get _engagementMetrics =>
      _firestore.collection('engagement_metrics');

  Future<void> createUserProfile(AppUser user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> updateUserProfileFields(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<AppUser?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromDoc(doc);
    });
  }

  Stream<List<AppUser>> watchAlumniUsers() {
    return _users.where('userType', isEqualTo: 'alumni').snapshots().map((
      snap,
    ) {
      final users = snap.docs.map(AppUser.fromDoc).toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  Stream<List<JobPost>> watchJobs() {
    return _jobs.snapshots().map((snap) {
      final jobs = snap.docs.map(JobPost.fromDoc).toList();
      jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return jobs;
    });
  }

  Future<void> createJob(JobPost job) async {
    await _jobs.add(job.toMap());
  }

  Stream<List<AppEvent>> watchEvents() {
    return _events.snapshots().map((snap) {
      final events = snap.docs.map(AppEvent.fromDoc).toList();
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      return events;
    });
  }

  Future<void> createEvent(AppEvent event) async {
    await _events.add(event.toMap());
  }

  Stream<List<Announcement>> watchAnnouncements() {
    return _announcements.snapshots().map((snap) {
      final items = snap.docs.map(Announcement.fromDoc).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<void> createAnnouncement(Announcement announcement) async {
    await _announcements.add(announcement.toMap());
  }

  Future<String> getOrCreateChatId(String uid1, String uid2) async {
    final ids = [uid1, uid2]..sort();
    final chatId = '${ids[0]}_${ids[1]}';

    final ref = _chats.doc(chatId);
    final existing = await ref.get();

    final data = <String, dynamic>{
      'participants': ids,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (!existing.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['lastMessage'] = '';
      data['lastSenderId'] = '';
      data['lastMessageAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(data, SetOptions(merge: true));
    return chatId;
  }

  Stream<List<ChatThread>> watchUserChats(String uid) {
    return _chats.where('participants', arrayContains: uid).snapshots().map((
      snap,
    ) {
      final threads = snap.docs.map(ChatThread.fromDoc).toList();
      threads.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return threads;
    });
  }

  Stream<List<ChatMessage>> watchChatMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          return snap.docs.map(ChatMessage.fromDoc).toList();
        });
  }

  Future<void> sendChatMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _chats.doc(chatId).set({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': text,
      'lastSenderId': senderId,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Mentorship Methods
  Future<void> createMentorshipSlot(MentorshipSlot slot) async {
    await _mentorshipSlots.add(slot.toMap());
  }

  Stream<List<MentorshipSlot>> watchMentorshipSlots() {
    return _mentorshipSlots.where('isActive', isEqualTo: true).snapshots().map((
      snap,
    ) {
      final slots = snap.docs
          .map((doc) => MentorshipSlot.fromMap(doc.data(), doc.id))
          .toList();
      slots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return slots;
    });
  }

  Stream<List<MentorshipSlot>> watchMyMentorshipSlots(String mentorId) {
    return _mentorshipSlots
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snap) {
          final slots = snap.docs
              .map((doc) => MentorshipSlot.fromMap(doc.data(), doc.id))
              .toList();
          slots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return slots;
        });
  }

  Future<void> createMentorshipRequest(MentorshipRequest request) async {
    await _mentorshipRequests.add(request.toMap());
  }

  Stream<List<MentorshipRequest>> watchMentorshipRequestsForMentor(
    String mentorId,
  ) {
    return _mentorshipRequests
        .where('mentorId', isEqualTo: mentorId)
        .snapshots()
        .map((snap) {
          final requests = snap.docs
              .map((doc) => MentorshipRequest.fromMap(doc.data(), doc.id))
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Stream<List<MentorshipRequest>> watchMentorshipRequestsForMentee(
    String menteeId,
  ) {
    return _mentorshipRequests
        .where('menteeId', isEqualTo: menteeId)
        .snapshots()
        .map((snap) {
          final requests = snap.docs
              .map((doc) => MentorshipRequest.fromMap(doc.data(), doc.id))
              .toList();
          requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return requests;
        });
  }

  Future<void> updateMentorshipRequest(String requestId, String status) async {
    await _mentorshipRequests.doc(requestId).update({
      'status': status,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createMentorshipSession(MentorshipSession session) async {
    await _mentorshipSessions.add(session.toMap());
  }

  Stream<List<MentorshipSession>> watchMentorshipSessions(String userId) {
    return _mentorshipSessions
        .where('mentorId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final sessions = snap.docs
              .map((doc) => MentorshipSession.fromMap(doc.data(), doc.id))
              .toList();
          sessions.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return sessions;
        });
  }

  Future<void> updateMentorshipSession(
    String sessionId,
    String status,
    String notes,
  ) async {
    await _mentorshipSessions.doc(sessionId).update({
      'status': status,
      'notes': notes,
    });
  }

  // Forum Methods
  Future<void> createForumPost(ForumPost post) async {
    await _forumPosts.add(post.toMap());
  }

  Stream<List<ForumPost>> watchForumPosts() {
    return _forumPosts.snapshots().map((snap) {
      final posts = snap.docs
          .map((doc) => ForumPost.fromMap(doc.data(), doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Stream<List<ForumPost>> watchForumPostsByCategory(String category) {
    return _forumPosts.where('category', isEqualTo: category).snapshots().map((
      snap,
    ) {
      final posts = snap.docs
          .map((doc) => ForumPost.fromMap(doc.data(), doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Stream<List<ForumPost>> watchMyForumPosts(String userId) {
    return _forumPosts.where('authorId', isEqualTo: userId).snapshots().map((
      snap,
    ) {
      final posts = snap.docs
          .map((doc) => ForumPost.fromMap(doc.data(), doc.id))
          .toList();
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  Future<void> likeForumPost(
    String postId,
    String userId,
    List<String> likedBy,
  ) async {
    await _forumPosts.doc(postId).update({
      'likedBy': likedBy,
      'likeCount': likedBy.length,
    });
  }

  Future<void> incrementForumPostViews(String postId) async {
    await _forumPosts.doc(postId).update({'views': FieldValue.increment(1)});
  }

  Future<void> createForumComment(ForumComment comment) async {
    await _forumComments.add(comment.toMap());
    await _forumPosts.doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Stream<List<ForumComment>> watchForumComments(String postId) {
    return _forumComments.where('postId', isEqualTo: postId).snapshots().map((
      snap,
    ) {
      final comments = snap.docs
          .map((doc) => ForumComment.fromMap(doc.data(), doc.id))
          .toList();
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return comments;
    });
  }

  Future<void> createForumCategory(ForumCategory category) async {
    await _forumCategories.add(category.toMap());
  }

  Stream<List<ForumCategory>> watchForumCategories() {
    return _forumCategories.snapshots().map((snap) {
      final categories = snap.docs
          .map((doc) => ForumCategory.fromMap(doc.data(), doc.id))
          .toList();
      categories.sort((a, b) => b.postCount.compareTo(a.postCount));
      return categories;
    });
  }

  // Resource Methods
  Future<void> createResource(Resource resource) async {
    await _resources.add(resource.toMap());
  }

  Stream<List<Resource>> watchResources() {
    return _resources.snapshots().map((snap) {
      final resources = snap.docs
          .map((doc) => Resource.fromMap(doc.data(), doc.id))
          .toList();
      resources.sort((a, b) => b.rating.compareTo(a.rating));
      return resources;
    });
  }

  Stream<List<Resource>> watchResourcesByCategory(String category) {
    return _resources.where('category', isEqualTo: category).snapshots().map((
      snap,
    ) {
      final resources = snap.docs
          .map((doc) => Resource.fromMap(doc.data(), doc.id))
          .toList();
      resources.sort((a, b) => b.rating.compareTo(a.rating));
      return resources;
    });
  }

  Stream<List<Resource>> watchMyResources(String authorId) {
    return _resources.where('authorId', isEqualTo: authorId).snapshots().map((
      snap,
    ) {
      final resources = snap.docs
          .map((doc) => Resource.fromMap(doc.data(), doc.id))
          .toList();
      resources.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return resources;
    });
  }

  Future<void> incrementResourceViews(String resourceId) async {
    await _resources.doc(resourceId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  Future<void> incrementResourceDownloads(String resourceId) async {
    await _resources.doc(resourceId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  Future<void> createResourceReview(ResourceReview review) async {
    await _resourceReviews.add(review.toMap());
    await _updateResourceRating(review.resourceId);
  }

  Stream<List<ResourceReview>> watchResourceReviews(String resourceId) {
    return _resourceReviews
        .where('resourceId', isEqualTo: resourceId)
        .snapshots()
        .map((snap) {
          final reviews = snap.docs
              .map((doc) => ResourceReview.fromMap(doc.data(), doc.id))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Future<void> _updateResourceRating(String resourceId) async {
    final reviews = await _resourceReviews
        .where('resourceId', isEqualTo: resourceId)
        .get();
    if (reviews.docs.isEmpty) return;

    // final totalRating = reviews.docs.fold<int>(0, (sum, doc) => sum + (doc.data()['rating'] ?? 0));
    final totalRating = reviews.docs.fold<int>(0, (sum, doc) {
      final rating = doc.data()['rating'];
      return sum + (rating is num ? rating.toInt() : 0);
    });
    final avgRating = totalRating / reviews.docs.length;

    await _resources.doc(resourceId).update({
      'rating': avgRating,
      'reviewCount': reviews.docs.length,
    });
  }

  Future<void> createResourceCategory(ResourceCategory category) async {
    await _resourceCategories.add(category.toMap());
  }

  Stream<List<ResourceCategory>> watchResourceCategories() {
    return _resourceCategories.snapshots().map((snap) {
      final categories = snap.docs
          .map((doc) => ResourceCategory.fromMap(doc.data(), doc.id))
          .toList();
      categories.sort((a, b) => b.resourceCount.compareTo(a.resourceCount));
      return categories;
    });
  }

  // Admin Methods
  Future<void> updateAdminStats(AdminStats stats) async {
    await _adminStats.doc('global').set(stats.toMap(), SetOptions(merge: true));
  }

  Stream<AdminStats?> watchAdminStats() {
    return _adminStats.doc('global').snapshots().map((doc) {
      if (!doc.exists) return null;
      return AdminStats.fromMap(doc.data()!);
    });
  }

  Future<void> createContentModerationItem(ContentModerationItem item) async {
    await _contentModeration.add(item.toMap());
  }

  Stream<List<ContentModerationItem>> watchContentModeration() {
    return _contentModeration
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) {
          final items = snap.docs
              .map((doc) => ContentModerationItem.fromMap(doc.data(), doc.id))
              .toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return items;
        });
  }

  Future<void> updateContentModerationItem(
    String itemId,
    String status,
    String? adminNotes,
  ) async {
    await _contentModeration.doc(itemId).update({
      'status': status,
      'adminNotes': adminNotes,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createUserReport(UserReport report) async {
    await _userReports.add(report.toMap());
  }

  Stream<List<UserReport>> watchUserReports() {
    return _userReports.where('status', isEqualTo: 'pending').snapshots().map((
      snap,
    ) {
      final reports = snap.docs
          .map((doc) => UserReport.fromMap(doc.data(), doc.id))
          .toList();
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    });
  }

  Future<void> updateUserReport(
    String reportId,
    String status,
    String? actionTaken,
  ) async {
    await _userReports.doc(reportId).update({
      'status': status,
      'actionTaken': actionTaken,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  // Analytics Methods
  Future<void> trackContentView(
    String contentId,
    String contentType,
    String authorId,
  ) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    await _analytics.add({
      'contentId': contentId,
      'contentType': contentType,
      'authorId': authorId,
      'views': FieldValue.increment(1),
      'date': dateKey,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> trackContentClick(
    String contentId,
    String contentType,
    String authorId,
  ) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month}-${today.day}';

    await _analytics.add({
      'contentId': contentId,
      'contentType': contentType,
      'authorId': authorId,
      'clicks': FieldValue.increment(1),
      'date': dateKey,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEngagementMetrics(
    String userId,
    String userName,
    String userType,
    String action,
  ) async {
    final ref = _engagementMetrics.doc(userId);
    final existing = await ref.get();

    final data = <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'lastActive': FieldValue.serverTimestamp(),
    };

    if (existing.exists) {
      final current = existing.data()!;
      switch (action) {
        case 'post':
          data['postsCreated'] = (current['postsCreated'] ?? 0) + 1;
          break;
        case 'comment':
          data['commentsMade'] = (current['commentsMade'] ?? 0) + 1;
          break;
        case 'like':
          data['likesGiven'] = (current['likesGiven'] ?? 0) + 1;
          break;
        case 'share':
          data['resourcesShared'] = (current['resourcesShared'] ?? 0) + 1;
          break;
        case 'mentorship':
          data['mentorshipSessions'] = (current['mentorshipSessions'] ?? 0) + 1;
          break;
        case 'event':
          data['eventsAttended'] = (current['eventsAttended'] ?? 0) + 1;
          break;
      }
    } else {
      switch (action) {
        case 'post':
          data['postsCreated'] = 1;
          break;
        case 'comment':
          data['commentsMade'] = 1;
          break;
        case 'like':
          data['likesGiven'] = 1;
          break;
        case 'share':
          data['resourcesShared'] = 1;
          break;
        case 'mentorship':
          data['mentorshipSessions'] = 1;
          break;
        case 'event':
          data['eventsAttended'] = 1;
          break;
      }
    }

    await ref.set(data, SetOptions(merge: true));
  }

  Stream<List<EngagementMetrics>> watchTopEngagedUsers() {
    return _engagementMetrics.snapshots().map((snap) {
      final metrics = snap.docs
          .map((doc) => EngagementMetrics.fromMap(doc.data()!))
          .toList();
      metrics.sort((a, b) => b.engagementScore.compareTo(a.engagementScore));
      return metrics.take(10).toList();
    });
  }

  Stream<EngagementMetrics?> watchUserEngagementMetrics(String userId) {
    return _engagementMetrics.doc(userId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return EngagementMetrics.fromMap(doc.data()!);
    });
  }

  // User-specific activity count streams
  Stream<int> watchUserJobCount(String userId) {
    return _jobs
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> watchUserEventCount(String userId) {
    return _events
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> watchUserAnnouncementCount(String userId) {
    return _announcements
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> watchUserForumPostCount(String userId) {
    return _forumPosts
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }

  Stream<int> watchUserForumCommentCount(String userId) {
    return _forumComments
        .where('authorId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.length);
  }
}
