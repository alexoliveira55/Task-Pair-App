import '../../core/constants/app_constants.dart';
import '../entities/pair_invite_entity.dart';
import '../repositories/pair_repository.dart';
import '../repositories/user_repository.dart';

class AcceptInviteUseCase {
  final PairRepository _pairRepository;
  final UserRepository _userRepository;

  AcceptInviteUseCase(this._pairRepository, this._userRepository);

  Future<void> execute({
    required PairInviteEntity invite,
    required String acceptingUserId,
  }) async {
    await _pairRepository.updateInviteStatus(
      invite.id,
      AppConstants.inviteStatusAccepted,
    );

    final pair = await _pairRepository.getPairById(invite.pairId);
    if (pair == null) {
      throw Exception('Pair not found');
    }

    final updatedPair = pair.copyWith(user2Id: acceptingUserId);
    await _pairRepository.updatePair(updatedPair);

    await _userRepository.updatePairId(acceptingUserId, invite.pairId);
  }
}
