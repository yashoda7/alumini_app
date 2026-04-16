import '../auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repo);
  final AuthRepository _repo;

  Future<void> call() => _repo.signOut();
}

