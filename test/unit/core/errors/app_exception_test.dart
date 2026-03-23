import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    group('AuthException', () {
      test('should store message and code', () {
        const exception =
            AuthException(message: 'Invalid email', code: 'invalid-email');

        expect(exception.message, 'Invalid email');
        expect(exception.code, 'invalid-email');
      });

      test('should have null code when not provided', () {
        const exception = AuthException(message: 'Error');

        expect(exception.code, isNull);
      });

      test('toString should contain message', () {
        const exception = AuthException(message: 'Test', code: 'code');

        expect(exception.toString(), 'AppException(message: Test, code: code)');
      });
    });

    group('FirestoreException', () {
      test('should create with message', () {
        const exception = FirestoreException(message: 'Write failed');

        expect(exception.message, 'Write failed');
      });
    });

    group('StorageException', () {
      test('should create with message', () {
        const exception = StorageException(message: 'Upload failed');

        expect(exception.message, 'Upload failed');
      });
    });

    group('NetworkException', () {
      test('should create with message', () {
        const exception = NetworkException(message: 'No internet');

        expect(exception.message, 'No internet');
      });
    });

    group('ValidationException', () {
      test('should create with message', () {
        const exception = ValidationException(message: 'Invalid input');

        expect(exception.message, 'Invalid input');
      });
    });

    group('NotFoundException', () {
      test('should create with message', () {
        const exception = NotFoundException(message: 'Not found');

        expect(exception.message, 'Not found');
      });
    });
  });
}
