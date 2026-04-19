import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';

/// Pure domain contract — no Firebase / Google SDK imports below this line.
/// Swap the implementation without touching a single screen or use case.
abstract class AuthRepository {
  /// Reactive stream of Firebase auth state (null = signed out).
  Stream<User?> authStateChanges();

  /// Triggers the Google account picker.
  /// Returns null if the user cancels.
  /// Throws on network / account-disabled errors.
  Future<AppUser?> signInWithGoogle();

  /// Signs out from Firebase AND Google (shows account picker next time).
  Future<void> signOut();

  /// Fetches a single [AppUser] snapshot from Firestore.
  Future<AppUser?> getUser(String uid);

  /// Saves the profile-completion fields and flips [isProfileComplete] to true.

  Future<void> saveUserProfile({
    required String uid,
    required String userType,
    required String department,
    required String year,
    String? areaOfInterest,
    String? bio,
    String? yearsOfExperience,
  });
}

