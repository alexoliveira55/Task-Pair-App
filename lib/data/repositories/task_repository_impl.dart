import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.tasksCollection);

  @override
  Future<TaskEntity?> getTaskById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TaskModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get task', code: e.code);
    }
  }

  @override
  Future<List<TaskEntity>> getTasksByPairId(String pairId) async {
    try {
      final snapshot = await _collection.where('pairId', isEqualTo: pairId).get();
      return snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get tasks', code: e.code);
    }
  }

  @override
  Future<TaskEntity> createTask(TaskEntity task) async {
    try {
      final docRef = await _collection.add(TaskModel.fromEntity(task).toMap());
      return task.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to create task', code: e.code);
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      await _collection.doc(task.id).update(TaskModel.fromEntity(task).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to update task', code: e.code);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to delete task', code: e.code);
    }
  }

  @override
  Stream<List<TaskEntity>> watchTasksByPairId(String pairId) {
    return _collection
        .where('pairId', isEqualTo: pairId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromMap(doc.data(), doc.id).toEntity())
            .toList());
  }
}
