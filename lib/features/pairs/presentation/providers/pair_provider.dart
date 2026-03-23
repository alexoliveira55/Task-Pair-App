import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';
import 'package:task_pair_app/data/repositories/pair_repository_impl.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/entities/pair_invite_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';

final pairRepositoryProvider = Provider((ref) {
  return PairRepositoryImpl(ref.watch(firestoreProvider));
});

final currentPairProvider = StreamProvider<PairEntity?>((ref) {
  final userAsync = ref.watch(currentUserEntityProvider);
  return userAsync.when(
    data: (user) {
      if (user == null || user.pairId == null) return Stream.value(null);
      return ref.watch(pairRepositoryProvider).watchPair(user.pairId!);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
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

class PairNotifier extends StateNotifier<AsyncValue<void>> {
  final PairRepositoryImpl _pairRepository;
  final Ref _ref;

  PairNotifier(this._pairRepository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> createPairAndInvite({
    required String pairName,
    required int scoreTarget,
    required String inviteEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      final pair = await _pairRepository.createPair(PairEntity(
        id: '',
        user1Id: currentUser.id,
        user2Id: '',
        createdAt: DateTime.now(),
        name: pairName,
        scoreTarget: scoreTarget,
      ));

      await _ref
          .read(userRepositoryProvider)
          .updatePairId(currentUser.id, pair.id);

      await _pairRepository.createInvite(PairInviteEntity(
        id: '',
        fromUserId: currentUser.id,
        toEmail: inviteEmail,
        pairId: pair.id,
        status: AppConstants.inviteStatusPending,
        createdAt: DateTime.now(),
      ));

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptInvite(PairInviteEntity invite) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      await _pairRepository.updateInviteStatus(
          invite.id, AppConstants.inviteStatusAccepted);

      final pair = await _pairRepository.getPairById(invite.pairId);
      if (pair == null) throw Exception('Pair not found');

      await _pairRepository.updatePair(pair.copyWith(user2Id: currentUser.id));
      await _ref
          .read(userRepositoryProvider)
          .updatePairId(currentUser.id, pair.id);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> declineInvite(String inviteId) async {
    state = const AsyncValue.loading();
    try {
      await _pairRepository.updateInviteStatus(
          inviteId, AppConstants.inviteStatusDeclined);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendInvite({
    required String pairId,
    required String inviteEmail,
  }) async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      await _pairRepository.createInvite(PairInviteEntity(
        id: '',
        fromUserId: currentUser.id,
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

  Future<void> leavePair() async {
    state = const AsyncValue.loading();
    try {
      final currentUser = _ref.read(currentUserEntityProvider).value;
      if (currentUser == null) throw Exception('Not authenticated');

      final pair = _ref.read(currentPairProvider).value;
      if (pair == null) throw Exception('No pair found');

      // Remove pair reference from user
      await _ref
          .read(userRepositoryProvider)
          .updatePairId(currentUser.id, null);

      // If the user is user1, try to set user2 as user1 and clear user2,
      // otherwise just clear user2. If both slots become empty, delete pair.
      final isUser1 = pair.user1Id == currentUser.id;
      final partnerId = isUser1 ? pair.user2Id : pair.user1Id;

      if (partnerId.isEmpty) {
        // No partner, just delete the pair
        await _pairRepository.deletePair(pair.id);
      } else {
        // Clear the leaving user's slot
        if (isUser1) {
          await _pairRepository
              .updatePair(pair.copyWith(user1Id: partnerId, user2Id: ''));
        } else {
          await _pairRepository.updatePair(pair.copyWith(user2Id: ''));
        }
      }

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
