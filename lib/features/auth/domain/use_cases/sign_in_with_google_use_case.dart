import '../../../../core/models/user_model.dart';
import '../auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repo);
  final AuthRepository _repo;

  /// Returns null = user cancelled the picker (not an error).
  /// Throws = real error (network, account disabled, etc.)
  Future<AppUser?> call() => _repo.signInWithGoogle();
}

