import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/score_entity.dart';
import '../../domain/repositories/score_repository.dart';
import '../models/score_model.dart';

class ScoreRepositoryImpl implements ScoreRepository {
  final FirebaseFirestore _firestore;

  ScoreRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.scoresCollection);

  @override
  Future<ScoreEntity?> getScoreByUserId(String userId, String pairId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('pairId', isEqualTo: pairId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return ScoreModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get score', code: e.code);
    }
  }

  @override
  Future<List<ScoreEntity>> getScoresByPairId(String pairId) async {
    try {
      final snapshot = await _collection.where('pairId', isEqualTo: pairId).get();
      return snapshot.docs
          .map((doc) => ScoreModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get scores', code: e.code);
    }
  }

  @override
  Future<void> upsertScore(ScoreEntity score) async {
    try {
      final existing = await getScoreByUserId(score.userId, score.pairId);
      if (existing != null) {
        await _collection.doc(existing.id).update(ScoreModel.fromEntity(score).toMap());
      } else {
        await _collection.add(ScoreModel.fromEntity(score).toMap());
      }
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to upsert score', code: e.code);
    }
  }

  @override
  Future<void> addPoints(String userId, String pairId, int points) async {
    try {
      final existing = await getScoreByUserId(userId, pairId);
      if (existing != null) {
        await _collection.doc(existing.id).update({
          'totalPoints': FieldValue.increment(points),
          'periodPoints': FieldValue.increment(points),
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        final newScore = ScoreEntity(
          id: '',
          pairId: pairId,
          userId: userId,
          totalPoints: points,
          periodPoints: points,
          updatedAt: DateTime.now(),
        );
        await _collection.add(ScoreModel.fromEntity(newScore).toMap());
      }
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to add points', code: e.code);
    }
  }

  @override
  Stream<List<ScoreEntity>> watchScoresByPairId(String pairId) {
    return _collection
        .where('pairId', isEqualTo: pairId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScoreModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
