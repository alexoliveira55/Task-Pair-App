import '../entities/pair_invite_entity.dart';
import '../repositories/pair_repository.dart';

class InviteToPairUseCase {
  final PairRepository _pairRepository;

  InviteToPairUseCase(this._pairRepository);

  Future<PairInviteEntity> execute({
    required String fromUserId,
    required String toEmail,
    required String pairId,
  }) async {
    return _pairRepository.createInvite(PairInviteEntity(
      id: '',
      fromUserId: fromUserId,
      toEmail: toEmail,
      pairId: pairId,
      status: 'pending',
      createdAt: DateTime.now(),
    ));
  }
}
