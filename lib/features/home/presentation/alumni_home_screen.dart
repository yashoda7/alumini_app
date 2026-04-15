import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/widgets/dashboard_widgets.dart';

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

class AlumniHomeScreen extends ConsumerWidget {
  const AlumniHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: DashboardHeader(
              title: "Your Alumni Hub",
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
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          
          // Quick Actions Strip
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  QuickActionCard(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    color: Colors.purple.shade500,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  ),
                  QuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'Messages',
                    color: Colors.pink.shade500,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InboxScreen())),
                  ),
                  QuickActionCard(
                    icon: Icons.people_outline,
                    title: 'Directory',
                    color: Colors.orange.shade500,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen())),
                  ),
                  QuickActionCard(
                    icon: Icons.analytics_outlined,
                    title: 'Analytics',
                    color: Colors.teal.shade500,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen())),
                  ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
      
          // BENTO LAYOUT FOR ALUMNI
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // BLOCK A: Mentorship Request (Wide)
                  StreamBuilder<List<MentorshipRequest>>(
                    stream: firestoreService.watchMentorshipRequestsForMentor(user.uid),
                    builder: (context, snapshot) {
                      final requests = snapshot.data ?? [];
                      final pending = requests.where((r) => r.status == 'pending').length;
                      
                      return BentoCard(
                        isLarge: true,
                        icon: Icons.inbox_outlined,
                        title: pending > 0 ? 'You have Pending Requests' : 'Mentorship Program',
                        subtitle: 'View and accept student mentorship requests',
                        dynamicData: pending > 0 ? '$pending PENDING' : 'NO PENDING REQUESTS',
                        baseColor: Colors.deepOrange,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MentorshipRequestsScreen())),
                      );
                    }
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // BLOCK B & C: Jobs and Events (Half squares)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: BentoCard(
                            icon: Icons.work_outline,
                            title: 'Post a Job',
                            subtitle: 'Hire talent from campus',
                            dynamicData: 'HIRING',
                            baseColor: Colors.blue,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobListScreen(canPost: true))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StreamBuilder<List<AppEvent>>(
                            stream: firestoreService.watchEvents(),
                            builder: (context, snapshot) {
                              final events = snapshot.data ?? [];
                              
                              return BentoCard(
                                icon: Icons.event_available_outlined,
                                title: 'Organize Event',
                                subtitle: 'Host meetups or sessions',
                                dynamicData: events.isNotEmpty ? '${events.length} ACTIVE' : 'HOST ONE',
                                baseColor: Colors.green,
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: true))),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
      
                  // BLOCK D & E (Another Row): Community and Resources
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: BentoCard(
                            icon: Icons.forum_outlined,
                            title: 'Forums',
                            subtitle: 'Join discussions',
                            dynamicData: 'COMMUNITY',
                            baseColor: Colors.deepPurple,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BentoCard(
                            icon: Icons.campaign_outlined,
                            title: 'Announce',
                            subtitle: 'Share updates',
                            dynamicData: 'BULLETIN',
                            baseColor: Colors.amber.shade700,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: true))),
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 16),
                  // BLOCK F: Admin (Wide)
                  if (user.userType == 'admin') // Or any condition for admin
                    BentoCard(
                      isLarge: true,
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Dashboard',
                      subtitle: 'Moderate content and users',
                      dynamicData: 'PLATFORM CONTROLS',
                      baseColor: Colors.redAccent,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminDashboardScreen())),
                    ),
                ],
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
