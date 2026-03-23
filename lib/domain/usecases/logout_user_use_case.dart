import '../repositories/auth_repository.dart';

class LogoutUserUseCase {
  final AuthRepository _authRepository;

  LogoutUserUseCase(this._authRepository);

  Future<void> execute() async {
    await _authRepository.signOut();
  }
}
