import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/app_exception.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _firestore.collection(path);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection, String id) async {
    try {
      return await _firestore.collection(collection).doc(id).get();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get document', code: e.code);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocuments(
      String collection, List<QueryFilter> filters) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);
      for (final filter in filters) {
        query = query.where(filter.field,
            isEqualTo: filter.isEqualTo,
            whereIn: filter.whereIn);
      }
      return await query.get();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to get documents', code: e.code);
    }
  }

  Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    try {
      final ref = await _firestore.collection(collection).add(data);
      return ref.id;
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to add document', code: e.code);
    }
  }

  Future<void> setDocument(
      String collection, String id, Map<String, dynamic> data,
      {bool merge = false}) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to set document', code: e.code);
    }
  }

  Future<void> updateDocument(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to update document', code: e.code);
    }
  }

  Future<void> deleteDocument(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw FirestoreException(
          message: e.message ?? 'Failed to delete document', code: e.code);
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(
      String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(
      String collection, List<QueryFilter> filters) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    for (final filter in filters) {
      query = query.where(filter.field,
          isEqualTo: filter.isEqualTo, whereIn: filter.whereIn);
    }
    return query.snapshots();
  }
}

class QueryFilter {
  final String field;
  final Object? isEqualTo;
  final List<Object?>? whereIn;

  const QueryFilter({
    required this.field,
    this.isEqualTo,
    this.whereIn,
  });
}
