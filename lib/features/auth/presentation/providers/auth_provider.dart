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

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

final currentUserEntityProvider = StreamProvider<UserEntity?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(userRepositoryProvider).watchUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

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
