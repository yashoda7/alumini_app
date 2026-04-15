import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/auth/presentation/profile_completion_screen.dart';
import 'features/home/presentation/alumni_home_screen.dart';
import 'features/home/presentation/student_home_screen.dart';
import 'firebase_options.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alumni App',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUser = ref.watch(currentUserProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Auth error'))),
      data: (firebaseUser) {
        if (firebaseUser == null) {
          return const AuthScreen();
        }

        return currentUser.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, __) => const Scaffold(
            body: Center(child: Text('Error loading profile')),
          ),
          data: (user) {
            // Firestore doc missing (safety net — normally created on sign-in)
            if (user == null) {
              return ProfileCompletionScreen(uid: firebaseUser.uid);
            }

            // Profile incomplete → block in onboarding until done
            if (!user.isProfileComplete) {
              return ProfileCompletionScreen(uid: user.uid);
            }

            // Route by role
            if (user.isAlumni) return const AlumniHomeScreen();
            return const StudentHomeScreen();
          },
        );
      },
    );
  }
}
