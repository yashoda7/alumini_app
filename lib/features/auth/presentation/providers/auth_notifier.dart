import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/app_providers.dart';

/// Drives the loading / error UI state on [AuthScreen] and
/// [ProfileCompletionScreen].
///
/// Navigation is NOT done here — it is driven entirely by the
/// [currentUserProvider] stream reacting to Firestore changes, so there
/// are no race conditions and routing logic stays in one place (AuthGate).
class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {} // starts idle

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithGoogleUseCaseProvider).call(),
    );
  }

  Future<void> saveProfile({
    required String uid,
    required String userType,
    required String department,
    required String year,
    String? areaOfInterest,
    String? bio,
    String? yearsOfExperience,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(saveUserProfileUseCaseProvider).call(
            uid: uid,
            userType: userType,
            department: department,
            year: year,
            areaOfInterest: areaOfInterest,
            bio: bio,
            yearsOfExperience: yearsOfExperience,
          ),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signOutUseCaseProvider).call(),
    );
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

