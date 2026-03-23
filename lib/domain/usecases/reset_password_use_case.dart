import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<void> execute(String email) async {
    await _authRepository.resetPassword(email);
  }
}
