import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../domain/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
/// This is the only place that knows about [AuthService] and [FirestoreService].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._auth, this._firestore);

  final AuthService _auth;
  final FirestoreService _firestore;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  Future<AppUser?> signInWithGoogle() async {
    final credential = await _auth.signInWithGoogle();
    if (credential == null) return null; // user cancelled — not an error

    final firebaseUser = credential.user!;

    // ── Returning user: just return their existing profile ──────────
    final existing = await _firestore.getUser(firebaseUser.uid);
    if (existing != null) return existing;

    // ── New user: create a minimal Firestore doc immediately ────────
    // isProfileComplete = false triggers the ProfileCompletionScreen in AuthGate.
    final newUser = AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      isProfileComplete: false,
      createdAt: DateTime.now(),
    );
    await _firestore.createUserProfile(newUser);
    return newUser;
  }

  @override
  Future<void> saveUserProfile({
    required String uid,
    required String userType,
    required String department,
    required String year,
    String? areaOfInterest,
    String? presentTechnologies,
    String? yearsOfExperience,
  }) =>
      _firestore.updateUserProfileFields(uid, {
        'userType': userType,
        'department': department,
        'year': year,
        if (areaOfInterest != null) 'areaOfInterest': areaOfInterest,
        if (presentTechnologies != null) 'presentTechnologies': presentTechnologies,
        if (yearsOfExperience != null) 'yearsOfExperience': yearsOfExperience,
        'isProfileComplete': true,
      });

  @override
  Future<AppUser?> getUser(String uid) => _firestore.getUser(uid);

  @override
  Future<void> signOut() => _auth.signOut();
}

