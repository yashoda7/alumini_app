import '../auth_repository.dart';

class SaveUserProfileUseCase {
  const SaveUserProfileUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call({
    required String uid,
    required String userType,
    required String department,
    required String year,
  }) => _repo.saveUserProfile(
        uid: uid,
        userType: userType,
        department: department,
        year: year,
      );
}

