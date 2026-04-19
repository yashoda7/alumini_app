import 'package:alumni_app/core/widgets/dashboard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── Header ────────────────────────────────────────────────────
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
                onProfileTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Quick Actions ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PremiumQuickActionCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Directory',
                        color: Colors.orange,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen()),
                        ),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.work_rounded,
                        title: 'Jobs',
                        color: Colors.blue.shade700,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false)),
                        ),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.event_rounded,
                        title: 'Events',
                        color: Colors.teal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: false)),
                        ),
                      ),
                      PremiumQuickActionCard(
                        icon: Icons.library_books_rounded,
                        title: 'Resources',
                        color: Colors.purple,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ResourceListScreen(canUpload: false)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Featured Event Card ────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(text: 'Next Event'),
                      const SizedBox(height: 14),
                      StreamBuilder<List<AppEvent>>(
                        stream: firestoreService.watchEvents(),
                        builder: (context, snapshot) {
                          final events = snapshot.data ?? [];
                          final next = events.isNotEmpty ? events.first : null;
                          return _FeaturedEventPoster(
                            event: next,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: false)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Announcement Banner ───────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _AnnouncementBanner(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: false)),
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Job Opportunities Carousel ─────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const _SectionTitle(text: 'Job Opportunities'),
                          GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false)),
                            ),
                            child: Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<JobPost>>(
                      stream: firestoreService.watchJobs(),
                      builder: (context, snapshot) {
                        final jobs = snapshot.data;

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _JobCarouselSkeleton();
                        }

                        if (jobs == null || jobs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _EmptyJobCard(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false)),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 145,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(left: 24, right: 12),
                            scrollDirection: Axis.horizontal,
                            itemCount: jobs.take(6).length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, i) => _JobChip(
                              job: jobs[i],
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const JobListScreen(canPost: false)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Forums Quick Access ────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _ForumPromoBanner(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true)),
                    ),
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

// ── Section Title ──────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    );
  }
}

// ── Featured Event Poster ──────────────────────────────────────────────────────
class _FeaturedEventPoster extends StatelessWidget {
  const _FeaturedEventPoster({required this.event, required this.onTap});
  final AppEvent? event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Empty / placeholder state — still looks great
    if (event == null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'COMING SOON',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No events yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back soon for upcoming events',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 8),
          ],
        ),
        ),
      );
    }

    // Real event — vivid poster card
    final dateStr = DateFormat('MMM d, h:mm a').format(event!.eventDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔥 UPCOMING',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.7), size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event!.title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event!.location.isNotEmpty ? event!.location : 'Location TBA',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ── Job Cards ──────────────────────────────────────────────────────────────────
class _JobChip extends StatelessWidget {
  const _JobChip({required this.job, required this.onTap});
  final JobPost job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.indigo, Colors.teal, Colors.orange, Colors.pink, Colors.purple, Colors.blue];
    final color = colors[job.title.hashCode.abs() % colors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.work_outline_rounded, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              job.company,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                job.location.isNotEmpty ? job.location : 'Remote',
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyJobCard extends StatelessWidget {
  const _EmptyJobCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.work_outline_rounded, color: Colors.grey, size: 24),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No job posts yet', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
                SizedBox(height: 2),
                Text('Alumni will post opportunities here', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCarouselSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 24, right: 12),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 170,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ── Announcement Banner ─────────────────────────────────────────────────────────
class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.blue.shade900,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image with Error Handling
              Positioned.fill(
                child: Image.asset(
                  'assets/images/announcement_banner_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.blue.shade700],
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade900.withOpacity(0.9),
                        Colors.blue.shade500.withOpacity(0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'IMPORTANT UPDATE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'New Announcements\nAre Live!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Check what\'s new',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Forum Promo Banner ─────────────────────────────────────────────────────────
class _ForumPromoBanner extends StatelessWidget {
  const _ForumPromoBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade900.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade900.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.forum_rounded, color: Colors.blue.shade900, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Join the Community',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ask questions, share knowledge',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade800.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
