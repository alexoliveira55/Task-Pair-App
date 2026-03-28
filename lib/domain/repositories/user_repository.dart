import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity?> getUserByEmail(String email);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Stream<UserEntity?> watchUser(String id);
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateIsAdmin(String userId, bool isAdmin);
}
