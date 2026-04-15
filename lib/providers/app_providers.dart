import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/user_model.dart';
import '../features/auth/data/auth_repository_impl.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/domain/use_cases/save_user_profile_use_case.dart';
import '../features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import '../features/auth/domain/use_cases/sign_out_use_case.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

// ── Services ──────────────────────────────────────────────────────────────────

/// Singleton instance of [AuthService].
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Singleton instance of [FirestoreService].
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// ── Auth state streams ────────────────────────────────────────────────────────

/// Stream of Firebase Auth state changes (nullable [User]).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Stream of the currently logged-in [AppUser].
/// Returns `null` when no user is signed in or the Firestore doc is missing.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final firebaseUser = ref.watch(authStateProvider).asData?.value;
  if (firebaseUser == null) return Stream.value(null);

  return ref.watch(firestoreServiceProvider).watchUser(firebaseUser.uid);
});

// ── Repository ────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authServiceProvider),
    ref.watch(firestoreServiceProvider),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────────

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
  (ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final saveUserProfileUseCaseProvider = Provider<SaveUserProfileUseCase>(
  (ref) => SaveUserProfileUseCase(ref.watch(authRepositoryProvider)),
);
