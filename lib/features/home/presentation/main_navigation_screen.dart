import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/premium_dashboard_widgets.dart';
import '../../events/presentation/event_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'alumni_home_screen.dart';
import 'student_home_screen.dart';
import '../../../providers/app_providers.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final List<Widget> screens = [
      user.isAlumni ? const AlumniHomeScreen() : const StudentHomeScreen(),
      const EventListScreen(canCreate: false), // Simplified for now, or use role specific
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      extendBody: true,
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
