import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class RegisterUserUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  RegisterUserUseCase(this._authRepository, this._userRepository);

  Future<UserEntity> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final authUser = await _authRepository.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    final user = UserEntity(
      id: authUser.id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _userRepository.createUser(user);
    return user;
  }
}
