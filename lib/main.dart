import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/user_model.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/alumni_home_screen.dart';
import 'screens/home/student_home_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alumni App',
      theme: AppTheme.light(),
      home: AuthGate(
        authService: authService,
        firestoreService: firestoreService,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authService,
    required this.firestoreService,
  });

  final AuthService authService;
  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges(),
      builder: (context, snapshot) {
        final firebaseUser = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (firebaseUser == null) {
          return AuthScreen(
            authService: authService,
            firestoreService: firestoreService,
          );
        }

        return StreamBuilder<AppUser?>(
          stream: firestoreService.watchUser(firebaseUser.uid),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final user = userSnap.data;
            if (user == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Profile missing')),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your profile was not found in Firestore.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: authService.signOut,
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (user.userType == 'alumni') {
              return AlumniHomeScreen(
                user: user,
                authService: authService,
                firestoreService: firestoreService,
              );
            }
            return StudentHomeScreen(
              user: user,
              authService: authService,
              firestoreService: firestoreService,
            );
          },
        );
      },
    );
  }
}
