import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/errors/app_exception.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  Future<String> uploadFile({
    required String path,
    required File file,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
          message: e.message ?? 'Upload failed', code: e.code);
    }
  }

  Future<String> uploadBytes({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata =
          contentType != null ? SettableMetadata(contentType: contentType) : null;
      final uploadTask = await ref.putData(
          Uint8List.fromList(bytes), metadata);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
          message: e.message ?? 'Upload failed', code: e.code);
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } on FirebaseException catch (e) {
      throw StorageException(
          message: e.message ?? 'Delete failed', code: e.code);
    }
  }

  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
          message: e.message ?? 'Failed to get URL', code: e.code);
    }
  }

  String taskExecutionPhotoPath(String executionId) =>
      'task_executions/$executionId/photo.jpg';

  String userAvatarPath(String userId) => 'users/$userId/avatar.jpg';
}
