import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task_validation_entity.dart';
import '../../domain/repositories/task_validation_repository.dart';
import '../models/task_validation_model.dart';

class TaskValidationRepositoryImpl implements TaskValidationRepository {
  final FirebaseFirestore _firestore;

  TaskValidationRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.taskValidationsCollection);

  @override
  Future<TaskValidationEntity?> getValidationById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TaskValidationModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get validation', code: e.code);
    }
  }

  @override
  Future<TaskValidationEntity?> getValidationByExecutionId(
      String executionId) async {
    try {
      final snapshot = await _collection
          .where('executionId', isEqualTo: executionId)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return TaskValidationModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get validation', code: e.code);
    }
  }

  @override
  Future<TaskValidationEntity> createValidation(
      TaskValidationEntity validation) async {
    try {
      // Denormalize pairId from the occurrence for efficient queries
      String? pairId;
      final occDoc = await _firestore
          .collection(FirestoreConstants.taskOccurrencesCollection)
          .doc(validation.occurrenceId)
          .get();
      if (occDoc.exists && occDoc.data() != null) {
        pairId = occDoc.data()!['pairId'] as String?;
      }

      final model = TaskValidationModel.fromEntity(validation, pairId: pairId);
      final docRef = await _collection.add(model.toMap());
      return validation.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create validation', code: e.code);
    }
  }

  @override
  Stream<List<TaskValidationEntity>> watchValidationsByPairId(String pairId) {
    return _collection.where('pairId', isEqualTo: pairId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                TaskValidationModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
