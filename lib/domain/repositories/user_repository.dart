import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity?> getUserByEmail(String email);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
  Future<void> updatePairId(String userId, String? pairId);
  Stream<UserEntity?> watchUser(String id);
}
