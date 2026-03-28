import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/pair_repository_impl.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/admin/presentation/providers/admin_provider.dart';

final pairRepositoryProvider = Provider((ref) {
  return PairRepositoryImpl(ref.watch(firestoreProvider));
});

/// All pairs for the current user (1:N — user can be requester or executor).
final myPairsProvider = StreamProvider<List<PairEntity>>((ref) {
  final userAsync = ref.watch(currentUserEntityProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(pairRepositoryProvider).watchPairsByUserId(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Pairs where the current user is the requester (solicitante).
final pairsAsRequesterProvider = Provider<List<PairEntity>>((ref) {
  final user = ref.watch(currentUserEntityProvider).value;
  if (user == null) return [];
  final pairs = ref.watch(myPairsProvider).value ?? [];
  return pairs.where((p) => p.requesterId == user.id).toList();
});

/// Pairs where the current user is the executor.
final pairsAsExecutorProvider = Provider<List<PairEntity>>((ref) {
  final user = ref.watch(currentUserEntityProvider).value;
  if (user == null) return [];
  final pairs = ref.watch(myPairsProvider).value ?? [];
  return pairs.where((p) => p.executorId == user.id).toList();
});

/// Currently selected pair (for task creation, viewing, etc.).
final selectedPairIdProvider = StateProvider<String?>((ref) => null);

/// The currently selected pair entity (resolved from selectedPairIdProvider).
final selectedPairProvider = Provider<PairEntity?>((ref) {
  final selectedId = ref.watch(selectedPairIdProvider);
  if (selectedId == null) return null;
  final pairs = ref.watch(myPairsProvider).value ?? [];
  try {
    return pairs.firstWhere((p) => p.id == selectedId);
  } catch (_) {
    return null;
  }
});

/// Legacy alias: resolves to the first pair or selected pair.
/// Used by providers that need a single pair context.
final currentPairProvider = Provider<PairEntity?>((ref) {
  final selected = ref.watch(selectedPairProvider);
  if (selected != null) return selected;
  final pairs = ref.watch(myPairsProvider).value ?? [];
  return pairs.isNotEmpty ? pairs.first : null;
});

final pendingInvitesProvider = StreamProvider<List<PairInviteEntity>>((ref) {
  final userAsync = ref.watch(currentUserEntityProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref.watch(pairRepositoryProvider).watchInvitesForEmail(user.email);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Invites sent by the current user.
final sentInvitesProvider = StreamProvider<List<PairInviteEntity>>((ref) {
  final userAsync = ref.watch(currentUserEntityProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return ref
          .watch(pairRepositoryProvider)
          .watchInvitesByFromUserId(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// All invites for non-admin users (admin only).
final adminAllInvitesProvider =
    FutureProvider<List<PairInviteEntity>>((ref) async {
  final isAdmin = ref.watch(isAdminProvider);
  if (!isAdmin) return [];

  final allUsers = await ref.watch(userRepositoryProvider).getAllUsers();
  final nonAdminUsers = allUsers.where((u) => !u.isAdmin).toList();

  final repo = ref.watch(pairRepositoryProvider);
  final allInvites = <PairInviteEntity>[];
  final seenIds = <String>{};

  for (final user in nonAdminUsers) {
    final invites = await repo.getInvitesForEmail(user.email);
    for (final invite in invites) {
      if (seenIds.add(invite.id)) {
        allInvites.add(invite);
      }
    }
  }

  return allInvites;
});

/// Users available for pairing: all users except the current user.
final availableUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final currentUser = ref.watch(currentUserEntityProvider).value;
  if (currentUser == null) return [];
  final allUsers = await ref.watch(userRepositoryProvider).getAllUsers();
  return allUsers.where((u) => u.id != currentUser.id).toList();
});

class PairNotifier extends StateNotifier<AsyncValue<void>> {
  final PairRepositoryImpl _pairRepository;
  final Ref _ref;

  PairNotifier(this._pairRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<({String uid, String email})> _requireAuth() async {
    final userEntity = _ref.read(currentUserEntityProvider).value;
    if (userEntity != null) {
      return (uid: userEntity.id, email: userEntity.email);
    }
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) {
      throw Exception('Not authenticated');
    }
    final userRepo = _ref.read(userRepositoryProvider);
    final existingUser = await userRepo.getUserById(firebaseUser.uid);
    if (existingUser == null) {
      await userRepo.createUser(UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        displayName: firebaseUser.displayName ?? '',
        createdAt: DateTime.now(),
      ));
    }
    return (uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  /// Send invite: fromUser is requester, toEmail is executor.
  Future<void> sendPairInvite({
    required String pairName,
    required int scoreTarget,
    required String inviteEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = await _requireAuth();

      await _pairRepository.createInvite(PairInviteEntity(
        id: '',
        fromUserId: auth.uid,
        toEmail: inviteEmail,
        pairId: '',
        status: AppConstants.inviteStatusPending,
        createdAt: DateTime.now(),
        pairName: pairName,
        scoreTarget: scoreTarget,
      ));

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Accept invite: fromUserId becomes requesterId, current user becomes executorId.
  Future<void> acceptInvite(PairInviteEntity invite) async {
    state = const AsyncValue.loading();
    try {
      final auth = await _requireAuth();

      if (invite.pairId.isEmpty) {
        await _pairRepository.createPair(PairEntity(
          id: '',
          requesterId: invite.fromUserId,
          executorId: auth.uid,
          createdAt: DateTime.now(),
          name: invite.pairName,
          scoreTarget: invite.scoreTarget,
        ));
      } else {
        await _pairRepository.setExecutorId(invite.pairId, auth.uid);
      }

      await _pairRepository.updateInviteStatus(
          invite.id, AppConstants.inviteStatusAccepted);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> declineInvite(String inviteId) async {
    state = const AsyncValue.loading();
    try {
      await _pairRepository.updateInviteStatus(
          inviteId, AppConstants.inviteStatusRejected);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Admin accepts an invite on behalf of the recipient user.
  Future<void> acceptInviteAsAdmin(PairInviteEntity invite) async {
    state = const AsyncValue.loading();
    try {
      final recipientUser = await _ref
          .read(userRepositoryProvider)
          .getUserByEmail(invite.toEmail);
      if (recipientUser == null) throw Exception('Recipient user not found');

      if (invite.pairId.isEmpty) {
        await _pairRepository.createPair(PairEntity(
          id: '',
          requesterId: invite.fromUserId,
          executorId: recipientUser.id,
          createdAt: DateTime.now(),
          name: invite.pairName,
          scoreTarget: invite.scoreTarget,
        ));
      } else {
        await _pairRepository.setExecutorId(invite.pairId, recipientUser.id);
      }

      await _pairRepository.updateInviteStatus(
          invite.id, AppConstants.inviteStatusAccepted);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendInvite({
    required String pairId,
    required String inviteUserId,
    required String inviteEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      final auth = await _requireAuth();

      await _pairRepository.createInvite(PairInviteEntity(
        id: '',
        fromUserId: auth.uid,
        toEmail: inviteEmail,
        pairId: pairId,
        status: AppConstants.inviteStatusPending,
        createdAt: DateTime.now(),
      ));

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Leave a specific pair. Deletes the pair entirely.
  Future<void> leavePair(PairEntity pair) async {
    state = const AsyncValue.loading();
    try {
      await _pairRepository.deletePair(pair.id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pairNotifierProvider =
    StateNotifierProvider<PairNotifier, AsyncValue<void>>((ref) {
  return PairNotifier(ref.watch(pairRepositoryProvider), ref);
});
