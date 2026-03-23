import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/reward_entity.dart';
import '../../domain/repositories/reward_repository.dart';
import '../models/reward_model.dart';

class RewardRepositoryImpl implements RewardRepository {
  final FirebaseFirestore _firestore;

  RewardRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.rewardsCollection);

  @override
  Future<List<RewardEntity>> getRewardsByPairId(String pairId) async {
    try {
      final snapshot =
          await _collection.where('pairId', isEqualTo: pairId).get();
      return snapshot.docs
          .map((doc) => RewardModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get rewards', code: e.code);
    }
  }

  @override
  Future<RewardEntity> createReward(RewardEntity reward) async {
    try {
      final docRef =
          await _collection.add(RewardModel.fromEntity(reward).toMap());
      return reward.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create reward', code: e.code);
    }
  }

  @override
  Future<void> updateReward(RewardEntity reward) async {
    try {
      await _collection
          .doc(reward.id)
          .update(RewardModel.fromEntity(reward).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update reward', code: e.code);
    }
  }

  @override
  Future<void> deleteReward(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to delete reward', code: e.code);
    }
  }

  @override
  Future<void> unlockReward(String rewardId, DateTime unlockedAt) async {
    try {
      await _collection.doc(rewardId).update({
        'isUnlocked': true,
        'unlockedAt': Timestamp.fromDate(unlockedAt),
      });
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to unlock reward', code: e.code);
    }
  }

  @override
  Stream<List<RewardEntity>> watchRewardsByPairId(String pairId) {
    return _collection.where('pairId', isEqualTo: pairId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RewardModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
