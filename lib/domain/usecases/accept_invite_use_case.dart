import '../../core/constants/app_constants.dart';
import '../entities/pair_invite_entity.dart';
import '../repositories/pair_repository.dart';

class AcceptInviteUseCase {
  final PairRepository _pairRepository;

  AcceptInviteUseCase(this._pairRepository);

  Future<void> execute({
    required PairInviteEntity invite,
    required String acceptingUserId,
  }) async {
    await _pairRepository.updateInviteStatus(
      invite.id,
      AppConstants.inviteStatusAccepted,
    );

    if (invite.pairId.isNotEmpty) {
      await _pairRepository.setExecutorId(invite.pairId, acceptingUserId);
    }
  }
}
