import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(ref.watch(firebaseAuthProvider));
});

final userRepositoryProvider = Provider((ref) {
  return UserRepositoryImpl(ref.watch(firestoreProvider));
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

  AuthNotifier(this._authService, this._userRepository)
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
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(userRepositoryProvider),
  );
});
