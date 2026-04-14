import 'package:flutter/material.dart';

import '../../models/analytics_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({
    super.key,
    required this.firestoreService,
  });

  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SectionHeader(title: 'Top Engaged Users'),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<List<EngagementMetrics>>(
            stream: firestoreService.watchTopEngagedUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final metrics = snapshot.data ?? [];

              if (metrics.isEmpty) {
                return AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'No engagement data yet',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  ...metrics.take(5).map((metric) => _EngagementCard(metric: metric)),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Platform Insights'),
          const SizedBox(height: AppSpacing.md),
          _InsightsCard(),
        ],
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  const _EngagementCard({required this.metric});

  final EngagementMetrics metric;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              metric.userName[0].toUpperCase(),
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.userName,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${metric.userType.toUpperCase()} • Score: ${metric.engagementScore.toStringAsFixed(1)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.post_add_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${metric.postsCreated}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${metric.commentsMade}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Metrics',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            label: 'Total Posts Created',
            value: 'Track user content creation',
            icon: Icons.post_add,
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            label: 'Comments Made',
            value: 'Track discussion participation',
            icon: Icons.comment,
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            label: 'Resources Shared',
            value: 'Track knowledge sharing',
            icon: Icons.share,
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            label: 'Mentorship Sessions',
            value: 'Track mentorship engagement',
            icon: Icons.school,
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightRow(
            label: 'Events Attended',
            value: 'Track event participation',
            icon: Icons.event,
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.titleSmall,
              ),
              Text(
                value,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PostAnalyticsScreen extends StatelessWidget {
  const PostAnalyticsScreen({
    super.key,
    required this.firestoreService,
    required this.contentId,
    required this.contentType,
    required this.title,
  });

  final FirestoreService firestoreService;
  final String contentId;
  final String contentType;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Analytics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            title,
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            contentType.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _AnalyticsCard(
            title: 'Views',
            value: 'Track how many times this content was viewed',
            icon: Icons.visibility_outlined,
            color: Colors.blue,
          ),
          const SizedBox(height: AppSpacing.md),
          _AnalyticsCard(
            title: 'Clicks',
            value: 'Track interactions with links or buttons',
            icon: Icons.touch_app_outlined,
            color: Colors.green,
          ),
          const SizedBox(height: AppSpacing.md),
          _AnalyticsCard(
            title: 'Engagement Rate',
            value: 'Calculate likes, comments, and shares',
            icon: Icons.trending_up_outlined,
            color: Colors.orange,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Note: Analytics data is collected in real-time as users interact with your content.',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
