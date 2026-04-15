import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/widgets/dashboard_widgets.dart';
import '../../announcements/presentation/announcement_list_screen.dart';
import '../../directory/presentation/alumni_directory_screen.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../forum/presentation/forum_list_screen.dart';
import '../../jobs/presentation/job_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../resources/presentation/resource_list_screen.dart';
import '../../../core/utils/dialog_utils.dart';

import '../../events/domain/event_model.dart';
import '../../jobs/domain/job_model.dart';
import '../../announcements/domain/announcement_model.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: DashboardHeader(
                title: "Discover what's happening today.",
                greeting: "Hi, ${user?.name?.split(' ').first ?? 'Student'}",
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
            
            // Quick Actions (Horizontal Strip)
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
                      icon: Icons.people_outline,
                      title: 'Alumni Dir',
                      color: Colors.orange.shade500,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen())),
                    ),
                    QuickActionCard(
                      icon: Icons.forum_outlined,
                      title: 'Forums',
                      color: Colors.pink.shade500,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true))),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // BENTO BOX GRID
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // BLOCK A: Large Wide Card (Events)
                    StreamBuilder<List<AppEvent>>(
                      stream: firestoreService.watchEvents(),
                      builder: (context, snapshot) {
                        final events = snapshot.data ?? [];
                        final nextEvent = events.isNotEmpty ? events.first : null;
                        
                        return BentoCard(
                          isLarge: true,
                          icon: Icons.event,
                          title: nextEvent?.title ?? 'No Upcoming Events',
                          subtitle: nextEvent != null ? '${nextEvent.location} • Tap to view' : 'Stay tuned for new tech meetups',
                          dynamicData: nextEvent != null ? 'UPCOMING EVENT' : '',
                          baseColor: Colors.blue,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: false))),
                        );
                      }
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // BLOCK B & C: Half width squares (Jobs & Resources)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: StreamBuilder<List<JobPost>>(
                              stream: firestoreService.watchJobs(),
                              builder: (context, snapshot) {
                                final jobs = snapshot.data ?? [];
                                final matches = jobs.where((j) => j.description.toLowerCase().contains((user?.department ?? '').toLowerCase())).length;
                                
                                return BentoCard(
                                  icon: Icons.work_outline,
                                  title: 'Career & Jobs',
                                  subtitle: jobs.isNotEmpty ? 'Connect with top tier alumni companies' : 'Find your path',
                                  dynamicData: matches > 0 ? '$matches MATCHES' : (jobs.isNotEmpty ? '${jobs.length} JOBS' : ''),
                                  baseColor: Colors.amber.shade700,
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false))),
                                );
                              }
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BentoCard(
                              icon: Icons.folder_open,
                              title: 'Resource Library',
                              subtitle: 'Access study guides & templates',
                              dynamicData: 'TRENDING',
                              baseColor: Colors.teal,
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResourceListScreen(canUpload: false))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // BLOCK D: Large Wide Card (Notice Board)
                    StreamBuilder<List<Announcement>>(
                      stream: firestoreService.watchAnnouncements(),
                      builder: (context, snapshot) {
                        final notices = snapshot.data ?? [];
                        final latest = notices.isNotEmpty ? notices.first : null;
                        
                        return BentoCard(
                          isLarge: true,
                          icon: Icons.campaign_outlined,
                          title: latest?.title ?? 'Notice Board',
                          subtitle: latest != null ? 'Tap to view announcement details' : 'No new notices',
                          dynamicData: latest != null ? 'LATEST UPDATE' : '',
                          baseColor: Colors.redAccent,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: false))),
                        );
                      }
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}
