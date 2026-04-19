import 'package:alumni_app/core/widgets/dashboard_widgets.dart';
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

    if (user == null) return const SizedBox.shrink();

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
                onProfileTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // ── My Impact Summary ────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _AlumniImpactCard(
                    uid: user.uid,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
                    ),
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Quick Actions Pills ────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _QuickActionPill(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Messages',
                        color: Colors.pink,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InboxScreen()),
                        ),
                      ),
                      _QuickActionPill(
                        icon: Icons.people_alt_rounded,
                        label: 'Directory',
                        color: Colors.orange,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AlumniDirectoryScreen()),
                        ),
                      ),
                      _QuickActionPill(
                        icon: Icons.analytics_rounded,
                        label: 'My Activity',
                        color: Colors.teal,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AnalyticsDashboardScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Primary Management Actions (Posters) ───────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _ManagementPoster(
                        title: 'Post a Job Opportunity',
                        subtitle: 'Hire top talent from your campus',
                        icon: Icons.work_rounded,
                        gradient: [Colors.blue.shade900, Colors.blue.shade600],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JobListScreen(canPost: true)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ManagementPoster(
                        title: 'Host an Event',
                        subtitle: 'Organize meetups or tech sessions',
                        icon: Icons.event_rounded,
                        gradient: [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EventListScreen(canCreate: true)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Secondary Actions Grid ─────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Forums',
                          icon: Icons.forum_rounded,
                          color: Colors.purple,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForumListScreen(canPost: true)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          title: 'Announce',
                          icon: Icons.campaign_rounded,
                          color: Colors.amber.shade700,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AnnouncementListScreen(canPost: true)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Mentorship & Admin ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeIn(
                delay: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _MentorshipStrip(
                        uid: user.uid,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MentorshipRequestsScreen()),
                        ),
                      ),
                      if (user.userType == 'admin') ...[
                        const SizedBox(height: 16),
                        _ActionCard(
                          title: 'Admin Dashboard',
                          icon: Icons.admin_panel_settings_rounded,
                          color: Colors.redAccent,
                          isWide: true,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── New Premium Alumni Components ──────────────────────────────────────────────

class _AlumniImpactCard extends ConsumerWidget {
  const _AlumniImpactCard({required this.uid, required this.onTap});
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Impact',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'See how you contribute to the community',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _ImpactStateItem(
                  stream: firestore.watchUserJobCount(uid),
                  label: 'Jobs Posted',
                  color: Colors.blue,
                ),
                _ImpactStateItem(
                  stream: firestore.watchUserEventCount(uid),
                  label: 'Events Hosted',
                  color: Colors.teal,
                ),
                _ImpactStateItem(
                  stream: firestore.watchUserForumPostCount(uid),
                  label: 'Forums',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactStateItem extends StatelessWidget {
  const _ImpactStateItem({required this.stream, required this.label, required this.color});
  final Stream<int> stream;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return Column(
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}

class _ManagementPoster extends StatelessWidget {
  const _ManagementPoster({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.icon, required this.color, required this.onTap, this.isWide = false});
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isWide ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
          ],
        ),
      ),
    );
  }
}

class _MentorshipStrip extends ConsumerWidget {
  const _MentorshipStrip({required this.uid, required this.onTap});
  final String uid;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.watch(firestoreServiceProvider);

    return StreamBuilder<List<MentorshipRequest>>(
      stream: firestore.watchMentorshipRequestsForMentor(uid),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? [];
        final pending = requests.where((r) => r.status == 'pending').length;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pending > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (pending > 0 ? Colors.red : Colors.green).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(
                  pending > 0 ? Icons.notification_important_rounded : Icons.verified_user_rounded,
                  color: pending > 0 ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pending > 0 ? 'You have $pending pending mentorship requests' : 'Your mentorship profile is active',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: pending > 0 ? Colors.red.shade900 : Colors.green.shade900,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        );
      },
    );
  }
}
