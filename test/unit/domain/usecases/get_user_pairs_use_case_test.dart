import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/domain/usecases/get_user_pairs_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetUserPairsUseCase useCase;
  late MockPairRepository mockPairRepo;
  late MockUserRepository mockUserRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    mockUserRepo = MockUserRepository();
    useCase = GetUserPairsUseCase(mockPairRepo, mockUserRepo);
  });

  group('GetUserPairsUseCase', () {
    test('should return pair when user has a pair', () async {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        createdAt: now,
        pairId: 'pair-1',
      );

      final pair = PairEntity(
        id: 'pair-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
        createdAt: now,
        name: 'Test Pair',
        scoreTarget: 100,
      );

      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => user);
      when(() => mockPairRepo.getPairById(any())).thenAnswer((_) async => pair);

      final result = await useCase.execute('user-1');

      expect(result, equals(pair));
    });

    test('should return null when user has no pair', () async {
      final user = UserEntity(
        id: 'user-1',
        email: 'test@example.com',
        createdAt: now,
      );

      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => user);

      final result = await useCase.execute('user-1');

      expect(result, isNull);
      verifyNever(() => mockPairRepo.getPairById(any()));
    });

    test('should return null when user is not found', () async {
      when(() => mockUserRepo.getUserById(any())).thenAnswer((_) async => null);

      final result = await useCase.execute('nonexistent');

      expect(result, isNull);
    });
  });
}
