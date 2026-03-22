abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

class FirestoreException extends AppException {
  const FirestoreException({required super.message, super.code});
}

class StorageException extends AppException {
  const StorageException({required super.message, super.code});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code});
}
