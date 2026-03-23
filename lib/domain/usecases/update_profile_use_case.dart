import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository _userRepository;

  UpdateProfileUseCase(this._userRepository);

  Future<void> execute({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = await _userRepository.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final updatedUser = user.copyWith(
      displayName: displayName ?? user.displayName,
      photoUrl: photoUrl ?? user.photoUrl,
    );

    await _userRepository.updateUser(updatedUser);
  }
}
