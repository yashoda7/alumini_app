import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/app_providers.dart';
import '../../../core/widgets/premium_dashboard_widgets.dart';
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

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final authService = ref.read(authServiceProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: PremiumDashboardHeader(
                title: "Discover what's\nhappening today",
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
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Quick Actions (Horizontal)
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
                        title: "My Profile",
                        color: Colors.indigo,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.people_alt_rounded,
                        title: "Alumni Dir",
                        color: Colors.orange,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen())),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.forum_rounded,
                        title: "Forums",
                        color: Colors.pink,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true))),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.grid_view_rounded,
                        title: "More",
                        color: Colors.teal,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Upcoming Events Section
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: StreamBuilder<List<AppEvent>>(
                    stream: firestoreService.watchEvents(),
                    builder: (context, snapshot) {
                      final events = snapshot.data ?? [];
                      final nextEvent = events.isNotEmpty ? events.first : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Upcoming Event",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (nextEvent != null)
                            PremiumEventCard(
                              tag: "Upcoming",
                              title: nextEvent.title,
                              location: nextEvent.location,
                              date: "APR 24",
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: false))),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(24),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text("No upcoming events scheduled."),
                            ),
                        ],
                      );
                    }
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Career & Resources Grid
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
                          title: "Career & Jobs",
                          description: "Find matches and careers",
                          baseColor: Colors.amber.shade800,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PremiumGridCard(
                          icon: Icons.library_books_rounded,
                          title: "Resources",
                          description: "Access templates & guides",
                          baseColor: Colors.blueAccent,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResourceListScreen(canUpload: false))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Latest Updates Section
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Latest Updates",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: false))),
                            child: const Text("View All"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<Announcement>>(
                        stream: firestoreService.watchAnnouncements(),
                        builder: (context, snapshot) {
                          final notices = snapshot.data ?? [];
                          if (notices.isEmpty) {
                            return const Center(child: Text("No updates yet."));
                          }
                          return Column(
                            children: notices.take(3).map((n) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      n.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                    ),
                                    // subtitle: Text(
                                    //   n.content,
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    // ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: false))),
                                  ),
                                  const Divider(height: 1),
                                ],
                              ),
                            )).toList(),
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
