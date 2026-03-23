import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<UserEntity?> authStateChanges();
  UserEntity? get currentUser;
}
