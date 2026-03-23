import '../entities/pair_entity.dart';
import '../entities/pair_invite_entity.dart';

abstract class PairRepository {
  Future<PairEntity?> getPairById(String id);
  Future<PairEntity> createPair(PairEntity pair);
  Future<void> updatePair(PairEntity pair);
  Future<void> deletePair(String id);
  Stream<PairEntity?> watchPair(String id);

  Future<PairInviteEntity> createInvite(PairInviteEntity invite);
  Future<List<PairInviteEntity>> getInvitesForEmail(String email);
  Future<void> updateInviteStatus(String inviteId, String status);
  Stream<List<PairInviteEntity>> watchInvitesForEmail(String email);
}
