import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/domain/usecases/update_profile_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late UpdateProfileUseCase useCase;
  late MockUserRepository mockUserRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockUserRepo = MockUserRepository();
    useCase = UpdateProfileUseCase(mockUserRepo);
  });

  setUpAll(() {
    registerFallbackValue(UserEntity(
      id: '',
      email: '',
      createdAt: DateTime.now(),
    ));
  });

  group('UpdateProfileUseCase', () {
    test('should update displayName', () async {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        displayName: 'Old Name',
        createdAt: now,
      );

      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => user);
      when(() => mockUserRepo.updateUser(any())).thenAnswer((_) async {});

      await useCase.execute(
        userId: 'user-1',
        displayName: 'New Name',
      );

      final captured =
          verify(() => mockUserRepo.updateUser(captureAny())).captured;
      final updatedUser = captured.first as UserEntity;
      expect(updatedUser.displayName, 'New Name');
    });

    test('should update photoUrl', () async {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        createdAt: now,
      );

      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => user);
      when(() => mockUserRepo.updateUser(any())).thenAnswer((_) async {});

      await useCase.execute(
        userId: 'user-1',
        photoUrl: 'https://example.com/photo.jpg',
      );

      final captured =
          verify(() => mockUserRepo.updateUser(captureAny())).captured;
      final updatedUser = captured.first as UserEntity;
      expect(updatedUser.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should throw when user not found', () async {
      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => null);

      expect(
        () => useCase.execute(userId: 'nonexistent'),
        throwsException,
      );
    });
  });
}
