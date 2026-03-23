import '../../core/constants/app_constants.dart';
import '../repositories/pair_repository.dart';

class RejectInviteUseCase {
  final PairRepository _pairRepository;

  RejectInviteUseCase(this._pairRepository);

  Future<void> execute(String inviteId) async {
    await _pairRepository.updateInviteStatus(
      inviteId,
      AppConstants.inviteStatusDeclined,
    );
  }
}
