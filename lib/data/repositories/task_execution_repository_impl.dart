import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task_execution_entity.dart';
import '../../domain/repositories/task_execution_repository.dart';
import '../models/task_execution_model.dart';

class TaskExecutionRepositoryImpl implements TaskExecutionRepository {
  final FirebaseFirestore _firestore;

  TaskExecutionRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.taskExecutionsCollection);

  @override
  Future<TaskExecutionEntity?> getExecutionById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TaskExecutionModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get execution', code: e.code);
    }
  }

  @override
  Future<TaskExecutionEntity?> getExecutionByOccurrenceId(String occurrenceId) async {
    try {
      final snapshot = await _collection.where('occurrenceId', isEqualTo: occurrenceId).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return TaskExecutionModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get execution', code: e.code);
    }
  }

  @override
  Future<TaskExecutionEntity> createExecution(TaskExecutionEntity execution) async {
    try {
      final docRef = await _collection.add(TaskExecutionModel.fromEntity(execution).toMap());
      return execution.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to create execution', code: e.code);
    }
  }

  @override
  Future<void> updateExecution(TaskExecutionEntity execution) async {
    try {
      await _collection.doc(execution.id).update(TaskExecutionModel.fromEntity(execution).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to update execution', code: e.code);
    }
  }

  @override
  Stream<List<TaskExecutionEntity>> watchExecutionsByTaskId(String taskId) {
    return _collection
        .where('taskId', isEqualTo: taskId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskExecutionModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
