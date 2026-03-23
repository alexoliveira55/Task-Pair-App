import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/domain/usecases/login_user_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late LoginUserUseCase useCase;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    useCase = LoginUserUseCase(mockAuthRepo);
  });

  group('LoginUserUseCase', () {
    test('should return user on successful sign in', () async {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Test',
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockAuthRepo.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => user);

      final result = await useCase.execute(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, equals(user));
      verify(() => mockAuthRepo.signIn(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('should propagate exception on failed sign in', () async {
      when(() => mockAuthRepo.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Invalid credentials'));

      expect(
        () => useCase.execute(
          email: 'test@example.com',
          password: 'wrong',
        ),
        throwsException,
      );
    });
  });
}
