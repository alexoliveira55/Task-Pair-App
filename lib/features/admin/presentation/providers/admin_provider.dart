import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/data/repositories/user_repository_impl.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';

/// Whether the current user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserEntityProvider).value;
  return user?.isAdmin ?? false;
});

/// All users in the system (admin-only).
final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getAllUsers();
});

class AdminNotifier extends StateNotifier<AsyncValue<void>> {
  final UserRepositoryImpl _userRepository;
  final fb.FirebaseAuth _firebaseAuth;
  final Ref _ref;

  AdminNotifier(this._userRepository, this._firebaseAuth, this._ref)
      : super(const AsyncValue.data(null));

  /// Register a new user on behalf of the admin.
  /// Uses Firebase Auth to create the account, then creates
  /// the Firestore user doc. After creation, signs back in
  /// as the admin user.
  Future<void> createUserForThirdParty({
    required String email,
    required String password,
    required String displayName,
    required String adminEmail,
    required String adminPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Create the new user in Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUser = credential.user!;
      await newUser.updateDisplayName(displayName);

      // Create the Firestore user document
      await _userRepository.createUser(UserEntity(
        id: newUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      ));

      // Sign back in as the admin user
      await _firebaseAuth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );

      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Try to restore admin session even if something fails
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (_) {}
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleAdmin(String userId, bool isAdmin) async {
    state = const AsyncValue.loading();
    try {
      await _userRepository.updateIsAdmin(userId, isAdmin);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminNotifierProvider =
    StateNotifierProvider<AdminNotifier, AsyncValue<void>>((ref) {
  return AdminNotifier(
    ref.watch(userRepositoryProvider),
    ref.watch(firebaseAuthProvider),
    ref,
  );
});
