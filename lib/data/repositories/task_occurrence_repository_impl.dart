import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task_occurrence_entity.dart';
import '../../domain/repositories/task_occurrence_repository.dart';
import '../models/task_occurrence_model.dart';

class TaskOccurrenceRepositoryImpl implements TaskOccurrenceRepository {
  final FirebaseFirestore _firestore;

  TaskOccurrenceRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.taskOccurrencesCollection);

  @override
  Future<TaskOccurrenceEntity?> getOccurrenceById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TaskOccurrenceModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get occurrence', code: e.code);
    }
  }

  @override
  Future<List<TaskOccurrenceEntity>> getOccurrencesByPairId(
      String pairId) async {
    try {
      final snapshot =
          await _collection.where('pairId', isEqualTo: pairId).get();
      return snapshot.docs
          .map((doc) =>
              TaskOccurrenceModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get occurrences', code: e.code);
    }
  }

  @override
  Future<List<TaskOccurrenceEntity>> getOccurrencesByTaskId(
      String taskId) async {
    try {
      final snapshot =
          await _collection.where('taskId', isEqualTo: taskId).get();
      return snapshot.docs
          .map((doc) =>
              TaskOccurrenceModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get occurrences', code: e.code);
    }
  }

  @override
  Future<List<TaskOccurrenceEntity>> getPendingOccurrences(
      String pairId) async {
    try {
      final snapshot = await _collection
          .where('pairId', isEqualTo: pairId)
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs
          .map((doc) =>
              TaskOccurrenceModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get pending occurrences',
          code: e.code);
    }
  }

  @override
  Future<List<TaskOccurrenceEntity>> getOccurrencesByStatus(
      String pairId, String status) async {
    try {
      final snapshot = await _collection
          .where('pairId', isEqualTo: pairId)
          .where('status', isEqualTo: status)
          .get();
      return snapshot.docs
          .map((doc) =>
              TaskOccurrenceModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get occurrences by status',
          code: e.code);
    }
  }

  @override
  Future<TaskOccurrenceEntity> createOccurrence(
      TaskOccurrenceEntity occurrence) async {
    try {
      final docRef = await _collection
          .add(TaskOccurrenceModel.fromEntity(occurrence).toMap());
      return occurrence.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to create occurrence', code: e.code);
    }
  }

  @override
  Future<void> updateOccurrenceStatus(String id, String status) async {
    try {
      await _collection.doc(id).update({'status': status});
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update occurrence', code: e.code);
    }
  }

  @override
  Future<void> updateOccurrenceExecutionId(
      String id, String executionId) async {
    try {
      await _collection.doc(id).update({'executionId': executionId});
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update occurrence executionId',
          code: e.code);
    }
  }

  @override
  Stream<List<TaskOccurrenceEntity>> watchOccurrencesByPairId(String pairId) {
    return _collection.where('pairId', isEqualTo: pairId).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                TaskOccurrenceModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
