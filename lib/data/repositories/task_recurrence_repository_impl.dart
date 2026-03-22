import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/task_recurrence_entity.dart';
import '../../domain/repositories/task_recurrence_repository.dart';
import '../models/task_recurrence_model.dart';

class TaskRecurrenceRepositoryImpl implements TaskRecurrenceRepository {
  final FirebaseFirestore _firestore;

  TaskRecurrenceRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.taskRecurrencesCollection);

  @override
  Future<TaskRecurrenceEntity?> getRecurrenceById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      return TaskRecurrenceModel.fromMap(doc.data()!, doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get recurrence', code: e.code);
    }
  }

  @override
  Future<TaskRecurrenceEntity?> getRecurrenceByTaskId(String taskId) async {
    try {
      final snapshot = await _collection.where('taskId', isEqualTo: taskId).limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return TaskRecurrenceModel.fromMap(doc.data(), doc.id).toEntity();
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to get recurrence', code: e.code);
    }
  }

  @override
  Future<TaskRecurrenceEntity> createRecurrence(TaskRecurrenceEntity recurrence) async {
    try {
      final docRef = await _collection.add(TaskRecurrenceModel.fromEntity(recurrence).toMap());
      return recurrence.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to create recurrence', code: e.code);
    }
  }

  @override
  Future<void> updateRecurrence(TaskRecurrenceEntity recurrence) async {
    try {
      await _collection.doc(recurrence.id).update(TaskRecurrenceModel.fromEntity(recurrence).toMap());
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to update recurrence', code: e.code);
    }
  }

  @override
  Future<void> deactivateRecurrence(String id) async {
    try {
      await _collection.doc(id).update({'isActive': false});
    } on FirebaseException catch (e) {
      throw FirestoreException(message: e.message ?? 'Failed to deactivate recurrence', code: e.code);
    }
  }
}
