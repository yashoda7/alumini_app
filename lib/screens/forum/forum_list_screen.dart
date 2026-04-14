import 'package:alumni_app/screens/forum/forum_post_screen.dart';
import 'package:flutter/material.dart';

import '../../models/forum_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({
    super.key,
    required this.firestoreService,
    required this.currentUser,
    required this.canPost,
  });

  final FirestoreService firestoreService;
  final Map<String, dynamic> currentUser;
  final bool canPost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion Forums'),
        actions: [
          if (canPost)
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ForumPostScreen(
                    firestoreService: firestoreService,
                    currentUser: currentUser,
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
            ),
        ],
      ),
      body: StreamBuilder<List<ForumPost>>(
        stream: firestoreService.watchForumPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading posts',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No discussions yet',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Start a conversation with the community',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ForumPostCard(
                  post: post,
                  firestoreService: firestoreService,
                  currentUser: currentUser,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ForumPostCard extends StatelessWidget {
  const _ForumPostCard({
    required this.post,
    required this.firestoreService,
    required this.currentUser,
  });

  final ForumPost post;
  final FirestoreService firestoreService;
  final Map<String, dynamic> currentUser;

  @override
  Widget build(BuildContext context) {
    final isLiked = post.isLikedBy(currentUser['uid'] ?? '');

    return AppElevatedCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForumDetailScreen(
            post: post,
            firestoreService: firestoreService,
            currentUser: currentUser,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  post.authorType == 'alumni'
                      ? Icons.work_outline
                      : Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${post.authorDepartment} • ${_formatDate(post.createdAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  post.category,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            post.title,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            post.content,
            style: AppTextStyles.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.views}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: isLiked
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.likeCount}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.comment_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.commentCount}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class ForumDetailScreen extends StatefulWidget {
  const ForumDetailScreen({
    super.key,
    required this.post,
    required this.firestoreService,
    required this.currentUser,
  });

  final ForumPost post;
  final FirestoreService firestoreService;
  final Map<String, dynamic> currentUser;

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.firestoreService.incrementForumPostViews(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      widget.post.category,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.post.title,
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Icon(
                        widget.post.authorType == 'alumni'
                            ? Icons.work_outline
                            : Icons.school_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        widget.post.authorName,
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '•',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatDate(widget.post.createdAt),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    widget.post.content,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          widget.post.isLikedBy(widget.currentUser['uid'] ?? '')
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                        ),
                        color: widget.post.isLikedBy(widget.currentUser['uid'] ?? '')
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      Text(
                        '${widget.post.likeCount}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.comment_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${widget.post.commentCount} comments',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            SectionHeader(title: 'Comments'),
            StreamBuilder<List<ForumComment>>(
              stream: widget.firestoreService.watchForumComments(widget.post.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        'No comments yet. Be the first to comment!',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _CommentCard(comment: comment),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
  padding: EdgeInsets.only(
    bottom: MediaQuery.of(context).viewInsets.bottom,
  ),
  child: SafeArea(
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                suffixIcon: IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
    );
  }

  final _commentController = TextEditingController();

  void _toggleLike() {
    final uid = widget.currentUser['uid'] ?? '';
    final likedBy = List<String>.from(widget.post.likedBy);

    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }

    widget.firestoreService.likeForumPost(widget.post.id, uid, likedBy);
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final comment = ForumComment(
      id: '',
      postId: widget.post.id,
      authorId: widget.currentUser['uid'] ?? '',
      authorName: widget.currentUser['name'] ?? 'User',
      authorType: widget.currentUser['userType'] ?? 'student',
      content: text,
      createdAt: DateTime.now(),
    );

    widget.firestoreService.createForumComment(comment);
    _commentController.clear();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final ForumComment comment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  comment.authorType == 'alumni'
                      ? Icons.work_outline
                      : Icons.school_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                comment.authorName,
                style: AppTextStyles.titleSmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '•',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _formatDate(comment.createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            comment.content,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
