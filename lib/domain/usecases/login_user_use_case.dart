import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUserUseCase {
  final AuthRepository _authRepository;

  LoginUserUseCase(this._authRepository);

  Future<UserEntity> execute({
    required String email,
    required String password,
  }) async {
    return _authRepository.signIn(email: email, password: password);
  }
}
