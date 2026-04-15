import '../../analytics/presentation/analytics_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/admin_model.dart';
import '../../../providers/app_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: StreamBuilder<AdminStats?>(
        stream: firestoreService.watchAdminStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data;

          if (stats == null) {
            return Center(
              child: Text(
                'No stats available',
                style: AppTextStyles.bodyMedium,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              _StatsOverview(stats: stats),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: AppSpacing.md),
              const _QuickActions(),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: 'Pending Reports'),
              const SizedBox(height: AppSpacing.md),
              const _PendingReports(),
            ],
          );
        },
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  const _StatsOverview({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Platform Overview', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              label: 'Total Users',
              value: stats.totalUsers.toString(),
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            _StatCard(
              label: 'Students',
              value: stats.totalStudents.toString(),
              icon: Icons.school_outlined,
              color: Colors.green,
            ),
            _StatCard(
              label: 'Alumni',
              value: stats.totalAlumni.toString(),
              icon: Icons.work_outline,
              color: Colors.purple,
            ),
            _StatCard(
              label: 'Jobs',
              value: stats.totalJobs.toString(),
              icon: Icons.work_outline,
              color: Colors.orange,
            ),
            _StatCard(
              label: 'Events',
              value: stats.totalEvents.toString(),
              icon: Icons.event_outlined,
              color: Colors.pink,
            ),
            _StatCard(
              label: 'Forum Posts',
              value: stats.totalForumPosts.toString(),
              icon: Icons.forum_outlined,
              color: Colors.teal,
            ),
            _StatCard(
              label: 'Resources',
              value: stats.totalResources.toString(),
              icon: Icons.folder_open_outlined,
              color: Colors.indigo,
            ),
            _StatCard(
              label: 'Mentorships',
              value: stats.totalMentorshipSlots.toString(),
              icon: Icons.school_outlined,
              color: Colors.cyan,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ActionButton(
          icon: Icons.access_alarms_outlined,
          label: 'Content Moderation',
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ModerationScreen())),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionButton(
          icon: Icons.people_outline,
          label: 'User Management',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UserManagementScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActionButton(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppElevatedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.titleMedium)),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

class _PendingReports extends ConsumerWidget {
  const _PendingReports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return StreamBuilder<List<ContentModerationItem>>(
      stream: firestoreService.watchContentModeration(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return AppCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('All caught up!', style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No pending reports to review',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...items.take(3).map((item) => _ModerationItemCard(item: item)),
            if (items.length > 3)
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModerationScreen()),
                ),
                child: Text(
                  'View all ${items.length} reports',
                  style: AppTextStyles.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ModerationItemCard extends StatelessWidget {
  const _ModerationItemCard({required this.item});

  final ContentModerationItem item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.report_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                item.type.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.title, style: AppTextStyles.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text('By ${item.authorName}', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Text('Reason: ${item.reason}', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Content Moderation')),
      body: StreamBuilder<List<ContentModerationItem>>(
        stream: firestoreService.watchContentModeration(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('All Clear', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No pending moderation items',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ModerationDetailCard(item: item),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModerationDetailCard extends ConsumerWidget {
  const _ModerationDetailCard({required this.item});

  final ContentModerationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesController = TextEditingController();

    return AppElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.report_outlined,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                item.type.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(item.title, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('By ${item.authorName}', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text('Report Reason', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Text(item.reason, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Admin Notes (optional)',
              hintText: 'Add notes for your decision...',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _takeAction(
                    context,
                    ref,
                    'rejected',
                    notesController.text,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: const Text('Reject Content'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _takeAction(
                    context,
                    ref,
                    'approved',
                    notesController.text,
                  ),
                  child: const Text('Approve Content'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takeAction(
    BuildContext context,
    WidgetRef ref,
    String status,
    String notes,
  ) async {
    await ref
        .read(firestoreServiceProvider)
        .updateContentModerationItem(
          item.id,
          status,
          notes.isEmpty ? null : notes,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved' ? 'Content approved' : 'Content rejected',
          ),
        ),
      );
    }
  }
}

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: StreamBuilder<List<UserReport>>(
        stream: firestoreService.watchUserReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.green,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('All Clear', style: AppTextStyles.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'No pending user reports',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _UserReportCard(report: report),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserReportCard extends ConsumerWidget {
  const _UserReportCard({required this.report});

  final UserReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionController = TextEditingController();

    return AppElevatedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  size: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'USER REPORT',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(report.reportedUserName, style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Report Reason', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.xs),
          Text(report.reason, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: actionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Action Taken (optional)',
              hintText: 'Describe the action taken...',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _takeAction(
                    context,
                    ref,
                    'dismissed',
                    actionController.text,
                  ),
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _takeAction(
                    context,
                    ref,
                    'action_taken',
                    actionController.text,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Take Action'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takeAction(
    BuildContext context,
    WidgetRef ref,
    String status,
    String action,
  ) async {
    await ref
        .read(firestoreServiceProvider)
        .updateUserReport(report.id, status, action.isEmpty ? null : action);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'action_taken' ? 'Action taken' : 'Report dismissed',
          ),
        ),
      );
    }
  }
}
