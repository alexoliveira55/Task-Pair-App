import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/domain/usecases/register_user_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late RegisterUserUseCase useCase;
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    useCase = RegisterUserUseCase(mockAuthRepo, mockUserRepo);
  });

  setUpAll(() {
    registerFallbackValue(UserEntity(
      id: '',
      email: '',
      createdAt: DateTime.now(),
    ));
  });

  group('RegisterUserUseCase', () {
    test('should register user, create user doc, and return user entity',
        () async {
      final authUser = UserEntity(
        id: 'auth-uid-1',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockAuthRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => authUser);

      when(() => mockUserRepo.createUser(any())).thenAnswer((_) async {});

      final result = await useCase.execute(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      expect(result.id, 'auth-uid-1');
      expect(result.email, 'test@example.com');
      expect(result.displayName, 'Test User');

      verify(() => mockAuthRepo.register(
            email: 'test@example.com',
            password: 'password123',
            displayName: 'Test User',
          )).called(1);
      verify(() => mockUserRepo.createUser(any())).called(1);
    });

    test('should register without displayName', () async {
      final authUser = UserEntity(
        id: 'auth-uid-1',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      when(() => mockAuthRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => authUser);

      when(() => mockUserRepo.createUser(any())).thenAnswer((_) async {});

      final result = await useCase.execute(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result.displayName, isNull);
    });

    test('should propagate exception when register fails', () async {
      when(() => mockAuthRepo.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenThrow(Exception('Email already in use'));

      expect(
        () => useCase.execute(
          email: 'test@example.com',
          password: 'password123',
        ),
        throwsException,
      );
    });
  });
}
