import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.usersCollection);

  @override
  Future<UserEntity?> getUserById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get user', code: e.code);
    }
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    try {
      final snapshot =
          await _collection.where('email', isEqualTo: email).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return UserModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get user', code: e.code);
    }
  }

  @override
  Future<void> createUser(UserEntity user) async {
    try {
      await _collection.doc(user.id).set(UserModel.fromEntity(user).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create user', code: e.code);
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _collection.doc(user.id).update(UserModel.fromEntity(user).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update user', code: e.code);
    }
  }

  @override
  Stream<UserEntity?> watchUser(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id).toEntity();
    });
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final snapshot = await _collection.orderBy('email').get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to list users', code: e.code);
    }
  }

  @override
  Future<void> updateIsAdmin(String userId, bool isAdmin) async {
    try {
      await _collection.doc(userId).update({'isAdmin': isAdmin});
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update admin status', code: e.code);
    }
  }
}
