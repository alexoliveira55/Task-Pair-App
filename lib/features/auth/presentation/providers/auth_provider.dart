import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:task_pair_app/data/repositories/user_repository_impl.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/services/firebase_auth_service.dart';
import 'package:task_pair_app/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseAuthProvider));
});

final userRepositoryProvider = Provider((ref) {
  return UserRepositoryImpl(ref.watch(firestoreProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

/// Resolves a UserEntity by user ID (cached per ID).
final userByIdProvider =
    FutureProvider.family<UserEntity?, String>((ref, userId) async {
  return ref.watch(userRepositoryProvider).getUserById(userId);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

final currentUserEntityProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final userRepo = ref.watch(userRepositoryProvider);
      // Ensure user document exists in Firestore on every auth session.
      // Handles cases where registration succeeded in Firebase Auth but
      // the Firestore doc was never created (e.g. platform channel errors).
      _ensureUserDoc(user, userRepo);
      return userRepo.watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

Future<void> _ensureUserDoc(User user, UserRepositoryImpl userRepo) async {
  try {
    final existing = await userRepo.getUserById(user.uid);
    if (existing == null) {
      await userRepo.createUser(UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        createdAt: DateTime.now(),
      ));
    }
  } catch (_) {
    // Best-effort — don't block the stream
  }
}

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuthService _authService;
  final UserRepositoryImpl _userRepository;
  final StorageService _storageService;
  final Ref _ref;

  AuthNotifier(
      this._authService, this._userRepository, this._storageService, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Defensive: if sign-in throws but the user IS signed in
      // (e.g. platform channel issues on desktop), treat as success.
      if (_authService.currentUser != null) {
        state = const AsyncValue.data(null);
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _authService.updateDisplayName(displayName);
      final user = credential.user!;
      final entity = UserEntity(
        id: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(entity);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      // Defensive: if registration throws but the user IS created,
      // ensure their Firestore document exists.
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        try {
          await _authService.updateDisplayName(displayName);
          final entity = UserEntity(
            id: currentUser.uid,
            email: email,
            displayName: displayName,
            createdAt: DateTime.now(),
          );
          await _userRepository.createUser(entity);
        } catch (_) {
          // User doc may already exist from a partial success
        }
        state = const AsyncValue.data(null);
        return;
      }
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    state = const AsyncValue.loading();
    try {
      await _authService.updateDisplayName(displayName);
      final user = _ref.read(currentUserEntityProvider).value;
      if (user != null) {
        await _userRepository.updateUser(
          user.copyWith(displayName: displayName),
        );
      }
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfilePhoto(Uint8List bytes) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(currentUserEntityProvider).value;
      if (user == null) throw Exception('Not authenticated');

      final path = _storageService.userAvatarPath(user.id);
      final downloadUrl = await _storageService.uploadBytes(
        path: path,
        bytes: bytes,
        contentType: 'image/jpeg',
      );

      await _userRepository.updateUser(
        user.copyWith(photoUrl: downloadUrl),
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(storageServiceProvider),
    ref,
  );
});
