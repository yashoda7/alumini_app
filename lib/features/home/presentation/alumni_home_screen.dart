import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/widgets/premium_dashboard_widgets.dart';

import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../analytics/presentation/analytics_dashboard_screen.dart';
import '../../announcements/presentation/announcement_list_screen.dart';
import '../../directory/presentation/alumni_directory_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../forum/presentation/forum_list_screen.dart';
import '../../jobs/presentation/job_list_screen.dart';
import '../../mentorship/presentation/mentorship_requests_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../chat/presentation/inbox_screen.dart';
import '../../../core/utils/dialog_utils.dart';

import '../../events/domain/event_model.dart';
import '../../mentorship/domain/mentorship_model.dart';

class AlumniHomeScreen extends ConsumerStatefulWidget {
  const AlumniHomeScreen({super.key});

  @override
  ConsumerState<AlumniHomeScreen> createState() => _AlumniHomeScreenState();
}

class _AlumniHomeScreenState extends ConsumerState<AlumniHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: PremiumDashboardHeader(
              title: "Your Alumni\nDashboard",
              greeting: "Hi, ${user.name.split(' ').first}",
              onLogout: () async {
                final ok = await confirmDialog(
                  context,
                  title: 'Logout',
                  message: 'Are you sure you want to logout?',
                  confirmText: 'Logout',
                );
                if (!ok) return;
                await authService.signOut();
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          
          // Quick Actions
          SliverToBoxAdapter(
            child: FadeIn(
              delay: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PremiumQuickActionCard(
                      icon: Icons.person_rounded,
                      title: 'Profile',
                      color: Colors.indigo,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    ),
                    PremiumQuickActionCard(
                      icon: Icons.chat_bubble_rounded,
                      title: 'Messages',
                      color: Colors.pink,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InboxScreen())),
                    ),
                    PremiumQuickActionCard(
                      icon: Icons.people_alt_rounded,
                      title: 'Directory',
                      color: Colors.orange,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen())),
                    ),
                    PremiumQuickActionCard(
                      icon: Icons.analytics_rounded,
                      title: 'Analytics',
                      color: Colors.teal,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
      
          // Mentorship Section
          SliverToBoxAdapter(
            child: FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StreamBuilder<List<MentorshipRequest>>(
                  stream: firestoreService.watchMentorshipRequestsForMentor(user.uid),
                  builder: (context, snapshot) {
                    final requests = snapshot.data ?? [];
                    final pending = requests.where((r) => r.status == 'pending').length;
                    
                    return PremiumEventCard(
                      tag: pending > 0 ? "Action Required" : "Mentorship",
                      title: pending > 0 ? "You have $pending new requests" : "Mentorship Program",
                      location: "Student Connections",
                      date: "ACTIVE",
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MentorshipRequestsScreen())),
                    );
                  }
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
          
          // Jobs and Events Grid
          SliverToBoxAdapter(
            child: FadeIn(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: PremiumGridCard(
                        icon: Icons.work_rounded,
                        title: 'Post a Job',
                        description: 'Hire campus talent',
                        baseColor: Colors.blue,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobListScreen(canPost: true))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PremiumGridCard(
                        icon: Icons.event_rounded,
                        title: 'Host Event',
                        description: 'Meetups & sessions',
                        baseColor: Colors.green,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: true))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Forums and Announcements
          SliverToBoxAdapter(
            child: FadeIn(
              delay: const Duration(milliseconds: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: PremiumGridCard(
                        icon: Icons.forum_rounded,
                        title: 'Forums',
                        description: 'Community talks',
                        baseColor: Colors.purple,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PremiumGridCard(
                        icon: Icons.campaign_rounded,
                        title: 'Announce',
                        description: 'Share updates',
                        baseColor: Colors.amber.shade700,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: true))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (user.userType == 'admin') ...[
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 1000),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PremiumGridCard(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin Dashboard',
                    description: 'Platform controls & moderation',
                    baseColor: Colors.redAccent,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
                  ),
                ),
              ),
            ),
          ],
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
