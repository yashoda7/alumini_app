import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('My Activity')),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SectionHeader(title: 'My Contributions'),
              const SizedBox(height: AppSpacing.md),

              // Jobs Posted
              _CountStatCard(
                stream: firestoreService.watchUserJobCount(user.uid),
                label: 'Jobs Posted',
                icon: Icons.work_outline_rounded,
                color: Colors.blue,
              ),
              const SizedBox(height: AppSpacing.md),

              // Events Created
              _CountStatCard(
                stream: firestoreService.watchUserEventCount(user.uid),
                label: 'Events Created',
                icon: Icons.event_rounded,
                color: Colors.green,
              ),
              const SizedBox(height: AppSpacing.md),

              // Announcements Posted
              _CountStatCard(
                stream: firestoreService.watchUserAnnouncementCount(user.uid),
                label: 'Announcements Posted',
                icon: Icons.campaign_rounded,
                color: Colors.orange,
              ),
              const SizedBox(height: AppSpacing.md),

              // Forum Posts
              _CountStatCard(
                stream: firestoreService.watchUserForumPostCount(user.uid),
                label: 'Forum Posts',
                icon: Icons.forum_rounded,
                color: Colors.purple,
              ),
              const SizedBox(height: AppSpacing.md),

              // Forum Comments
              _CountStatCard(
                stream: firestoreService.watchUserForumCommentCount(user.uid),
                label: 'Forum Comments',
                icon: Icons.comment_rounded,
                color: Colors.teal,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

class _CountStatCard extends StatelessWidget {
  const _CountStatCard({
    required this.stream,
    required this.label,
    required this.icon,
    required this.color,
  });

  final Stream<int> stream;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return AppCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(label, style: AppTextStyles.titleMedium),
              ),
              isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Text(
                      '$count',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }
}

// Keep PostAnalyticsScreen for potential future use
class PostAnalyticsScreen extends StatelessWidget {
  const PostAnalyticsScreen({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.title,
  });

  final String contentId;
  final String contentType;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(title, style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contentType.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
