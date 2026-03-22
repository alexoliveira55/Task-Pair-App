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
      throw FirestoreException(message: e.message ?? 'Failed to get validation', code: e.code);
    }
  }

  @override
  Future<TaskValidationEntity?> getValidationByExecutionId(String executionId) async {
    try {
      final snapshot = await _collection.where('executionId', isEqualTo: executionId).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return TaskValidationModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get validation', code: e.code);
    }
  }

  @override
  Future<TaskValidationEntity> createValidation(TaskValidationEntity validation) async {
    try {
      final docRef = await _collection.add(TaskValidationModel.fromEntity(validation).toMap());
      return validation.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to create validation', code: e.code);
    }
  }

  @override
  Stream<List<TaskValidationEntity>> watchValidationsByPairId(String pairId) {
    // Validations are linked via occurrence/execution, not directly to pairId.
    // We query by occurrenceId which should be pre-fetched or filtered client-side.
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TaskValidationModel.fromMap(doc.data(), doc.id).toEntity())
        .toList());
  }
}
