import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/errors/failure.dart';

void main() {
  group('Failure', () {
    group('AuthFailure', () {
      test('should store message and code', () {
        const failure =
            AuthFailure(message: 'Invalid credentials', code: 'auth-error');

        expect(failure.message, 'Invalid credentials');
        expect(failure.code, 'auth-error');
      });

      test('should have null code when not provided', () {
        const failure = AuthFailure(message: 'Error');

        expect(failure.code, isNull);
      });

      test('should support equality via Equatable', () {
        const failure1 = AuthFailure(message: 'Error', code: 'code');
        const failure2 = AuthFailure(message: 'Error', code: 'code');
        const failure3 = AuthFailure(message: 'Different');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('props should contain message and code', () {
        const failure = AuthFailure(message: 'Error', code: 'code');

        expect(failure.props, ['Error', 'code']);
      });
    });

    group('FirestoreFailure', () {
      test('should create with message', () {
        const failure = FirestoreFailure(message: 'Write failed');
        expect(failure.message, 'Write failed');
      });
    });

    group('StorageFailure', () {
      test('should create with message', () {
        const failure = StorageFailure(message: 'Upload failed');
        expect(failure.message, 'Upload failed');
      });
    });

    group('NetworkFailure', () {
      test('should create with message', () {
        const failure = NetworkFailure(message: 'No internet');
        expect(failure.message, 'No internet');
      });
    });

    group('ValidationFailure', () {
      test('should create with message', () {
        const failure = ValidationFailure(message: 'Invalid input');
        expect(failure.message, 'Invalid input');
      });
    });

    group('NotFoundFailure', () {
      test('should create with message', () {
        const failure = NotFoundFailure(message: 'Not found');
        expect(failure.message, 'Not found');
      });
    });

    group('UnknownFailure', () {
      test('should create with message', () {
        const failure = UnknownFailure(message: 'Unknown error');
        expect(failure.message, 'Unknown error');
      });
    });
  });
}
