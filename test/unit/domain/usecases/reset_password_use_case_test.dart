import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/usecases/reset_password_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    useCase = ResetPasswordUseCase(mockAuthRepo);
  });

  group('ResetPasswordUseCase', () {
    test('should call resetPassword on auth repository', () async {
      when(() => mockAuthRepo.resetPassword(any())).thenAnswer((_) async {});

      await useCase.execute('test@example.com');

      verify(() => mockAuthRepo.resetPassword('test@example.com')).called(1);
    });

    test('should propagate exception when resetPassword fails', () async {
      when(() => mockAuthRepo.resetPassword(any()))
          .thenThrow(Exception('User not found'));

      expect(
        () => useCase.execute('test@example.com'),
        throwsException,
      );
    });
  });
}
