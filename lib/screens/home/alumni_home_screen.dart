import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/feature_tile.dart';
import '../../widgets/section_header.dart';
import '../admin/admin_dashboard_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../directory/alumni_directory_screen.dart';
import '../events/event_list_screen.dart';
import '../forum/forum_list_screen.dart';
import '../jobs/job_list_screen.dart';
import '../mentorship/mentorship_requests_screen.dart';
import '../mentorship/mentorship_sessions_screen.dart';
import '../mentorship/mentorship_slot_create_screen.dart';
import '../profile/profile_screen.dart';
import '../resources/resource_list_screen.dart';
import '../chat/inbox_screen.dart';
import '../../utils/dialog_utils.dart';

class AlumniHomeScreen extends StatelessWidget {
  const AlumniHomeScreen({
    super.key,
    required this.user,
    required this.authService,
    required this.firestoreService,
  });

  final AppUser user;
  final AuthService authService;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              final ok = await confirmDialog(
                context,
                title: 'Logout',
                message: 'Are you sure you want to logout?',
                confirmText: 'Logout',
              );
              if (!ok) return;
              await authService.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.xl),
          _buildQuickActions(context),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Create & Share'),
          const SizedBox(height: AppSpacing.md),
          _buildCreateSection(context),
          // const SizedBox(height: AppSpacing.xl),
          // SectionHeader(title: 'Mentorship'),
          // const SizedBox(height: AppSpacing.md),
          // _buildMentorshipSection(context),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Resources'),
          const SizedBox(height: AppSpacing.md),
          _buildResourcesSection(context),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Community'),
          const SizedBox(height: AppSpacing.md),
          _buildCommunitySection(context),
          const SizedBox(height: AppSpacing.xl),
          // SectionHeader(title: 'Admin & Analytics'),
          // const SizedBox(height: AppSpacing.md),
          // _buildAdminSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, ${user.name}',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${user.department} • ${user.year}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FeatureTile(
            title: 'My Profile',
            subtitle: 'View and edit',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    user: user,
                    firestoreService: firestoreService,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FeatureTile(
            title: 'Messages',
            subtitle: 'Student chats',
            icon: Icons.chat_bubble_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InboxScreen(
                    currentUser: user,
                    firestoreService: firestoreService,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreateSection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Post a Job',
          subtitle: 'Create job openings for students',
          icon: Icons.work_outline,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JobListScreen(
                  firestoreService: firestoreService,
                  canPost: true,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Create Event',
          subtitle: 'Organize alumni meetups/events',
          icon: Icons.event_available_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventListScreen(
                  firestoreService: firestoreService,
                  canCreate: true,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Post Announcement',
          subtitle: 'Share updates with students',
          icon: Icons.campaign_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AnnouncementListScreen(
                  firestoreService: firestoreService,
                  canPost: true,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Alumni Directory',
          subtitle: 'View and connect with alumni',
          icon: Icons.people_alt_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AlumniDirectoryScreen(
                  firestoreService: firestoreService,
                  currentUser: user,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Discussion Forums',
          subtitle: 'Join and create discussions',
          icon: Icons.forum_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ForumListScreen(
                  firestoreService: firestoreService,
                  currentUser: user.toMap(),
                  canPost: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMentorshipSection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Create Mentorship Slot',
          subtitle: 'Offer mentorship to students',
          icon: Icons.add_circle_outline,
          color: Theme.of(context).colorScheme.secondary,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MentorshipSlotCreateScreen(
                  user: user,
                  firestoreService: firestoreService,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Mentorship Requests',
          subtitle: 'View student requests',
          icon: Icons.inbox_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MentorshipRequestsScreen(
                  firestoreService: firestoreService,
                  mentorId: user.uid,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'My Sessions',
          subtitle: 'View scheduled sessions',
          icon: Icons.calendar_today_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MentorshipSessionsScreen(
                  firestoreService: firestoreService,
                  userId: user.uid,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResourcesSection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Resource Library',
          subtitle: 'Browse and upload resources',
          icon: Icons.folder_open_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResourceListScreen(
                  firestoreService: firestoreService,
                  currentUser: user.toMap(),
                  canUpload: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Admin Dashboard',
          subtitle: 'Moderate content and manage users',
          icon: Icons.admin_panel_settings_outlined,
          color: Theme.of(context).colorScheme.error,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminDashboardScreen(
                  firestoreService: firestoreService,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Analytics Dashboard',
          subtitle: 'View platform engagement metrics',
          icon: Icons.analytics_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AnalyticsDashboardScreen(
                  firestoreService: firestoreService,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
