import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/feature_tile.dart';
import '../../widgets/section_header.dart';
import '../admin/admin_dashboard_screen.dart';
import '../announcements/announcement_list_screen.dart';
import '../directory/alumni_directory_screen.dart';
import '../events/event_list_screen.dart';
import '../forum/forum_list_screen.dart';
import '../jobs/job_list_screen.dart';
import '../mentorship/mentorship_list_screen.dart';
import '../mentorship/mentorship_sessions_screen.dart';
import '../profile/profile_screen.dart';
import '../resources/resource_list_screen.dart';
import '../../utils/dialog_utils.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({
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
        title: const Text('Student Dashboard'),
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
          SectionHeader(title: 'Explore'),
          const SizedBox(height: AppSpacing.md),
          _buildExploreSection(context),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Growth & Learning'),
          const SizedBox(height: AppSpacing.md),
          _buildGrowthSection(context),
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
            title: 'Alumni',
            subtitle: 'Search directory',
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
        ),
      ],
    );
  }

  Widget _buildExploreSection(BuildContext context) {
    return Column(
      children: [
        FeatureTile(
          title: 'Job Posts',
          subtitle: 'View jobs posted by alumni',
          icon: Icons.work_outline,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => JobListScreen(
                  firestoreService: firestoreService,
                  canPost: false,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Events',
          subtitle: 'View upcoming events',
          icon: Icons.event_available_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventListScreen(
                  firestoreService: firestoreService,
                  canCreate: false,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Announcements',
          subtitle: 'View announcements',
          icon: Icons.campaign_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AnnouncementListScreen(
                  firestoreService: firestoreService,
                  canPost: false,
                  currentUid: user.uid,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGrowthSection(BuildContext context) {
    return Column(
      children: [
        // FeatureTile(
        //   title: 'Mentorship',
        //   subtitle: 'Connect with alumni mentors',
        //   icon: Icons.school_outlined,
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (_) => MentorshipListScreen(
        //           firestoreService: firestoreService,
        //           currentUser: user,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        // const SizedBox(height: AppSpacing.md),
        // FeatureTile(
        //   title: 'My Sessions',
        //   subtitle: 'View mentorship sessions',
        //   icon: Icons.calendar_today_outlined,
        //   onTap: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (_) => MentorshipSessionsScreen(
        //           firestoreService: firestoreService,
        //           userId: user.uid,
        //         ),
        //       ),
        //     );
        //   },
        // ),
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Discussion Forums',
          subtitle: 'Join community discussions',
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
        const SizedBox(height: AppSpacing.md),
        FeatureTile(
          title: 'Resource Library',
          subtitle: 'Access learning resources',
          icon: Icons.folder_open_outlined,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResourceListScreen(
                  firestoreService: firestoreService,
                  currentUser: user.toMap(),
                  canUpload: false,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
