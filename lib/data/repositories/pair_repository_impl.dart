import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/pair_entity.dart';
import '../../domain/entities/pair_invite_entity.dart';
import '../../domain/repositories/pair_repository.dart';
import '../models/pair_model.dart';
import '../models/pair_invite_model.dart';

class PairRepositoryImpl implements PairRepository {
  final FirebaseFirestore _firestore;

  PairRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _pairsCollection =>
      _firestore.collection(FirestoreConstants.pairsCollection);

  CollectionReference<Map<String, dynamic>> get _invitesCollection =>
      _firestore.collection(FirestoreConstants.pairInvitesCollection);

  @override
  Future<PairEntity?> getPairById(String id) async {
    try {
      final doc = await _pairsCollection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return PairModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get pair', code: e.code);
    }
  }

  @override
  Future<PairEntity> createPair(PairEntity pair) async {
    try {
      final docRef =
          await _pairsCollection.add(PairModel.fromEntity(pair).toMap());
      return pair.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create pair', code: e.code);
    }
  }

  @override
  Future<void> updatePair(PairEntity pair) async {
    try {
      await _pairsCollection
          .doc(pair.id)
          .update(PairModel.fromEntity(pair).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update pair', code: e.code);
    }
  }

  @override
  Future<void> deletePair(String id) async {
    try {
      await _pairsCollection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to delete pair', code: e.code);
    }
  }

  @override
  Stream<PairEntity?> watchPair(String id) {
    return _pairsCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return PairModel.fromMap(doc.data()!, doc.id).toEntity();
    });
  }

  @override
  Future<PairInviteEntity> createInvite(PairInviteEntity invite) async {
    try {
      final docRef = await _invitesCollection
          .add(PairInviteModel.fromEntity(invite).toMap());
      return invite.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create invite', code: e.code);
    }
  }

  @override
  Future<List<PairInviteEntity>> getInvitesForEmail(String email) async {
    try {
      final snapshot =
          await _invitesCollection.where('toEmail', isEqualTo: email).get();
      return snapshot.docs
          .map((doc) => PairInviteModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get invites', code: e.code);
    }
  }

  @override
  Future<void> updateInviteStatus(String inviteId, String status) async {
    try {
      await _invitesCollection.doc(inviteId).update({'status': status});
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update invite', code: e.code);
    }
  }

  @override
  Stream<List<PairInviteEntity>> watchInvitesForEmail(String email) {
    return _invitesCollection
        .where('toEmail', isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => PairInviteModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
