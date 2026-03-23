import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/usecases/create_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late CreatePairUseCase useCase;
  late MockPairRepository mockPairRepo;
  late MockUserRepository mockUserRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    mockUserRepo = MockUserRepository();
    useCase = CreatePairUseCase(mockPairRepo, mockUserRepo);
  });

  setUpAll(() {
    registerFallbackValue(PairEntity(
      id: '',
      user1Id: '',
      user2Id: '',
      createdAt: DateTime.now(),
      name: '',
      scoreTarget: 0,
    ));
  });

  group('CreatePairUseCase', () {
    test('should create pair and update both users pairId', () async {
      final createdPair = PairEntity(
        id: 'pair-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
        createdAt: now,
        name: 'Test Pair',
        scoreTarget: 100,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});

      final result = await useCase.execute(
        user1Id: 'user-1',
        user2Id: 'user-2',
        name: 'Test Pair',
      );

      expect(result.id, 'pair-1');
      expect(result.name, 'Test Pair');
      verify(() => mockPairRepo.createPair(any())).called(1);
      verify(() => mockUserRepo.updatePairId('user-1', 'pair-1')).called(1);
      verify(() => mockUserRepo.updatePairId('user-2', 'pair-1')).called(1);
    });

    test('should use default scoreTarget of 100', () async {
      final createdPair = PairEntity(
        id: 'pair-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
        createdAt: now,
        name: 'Test',
        scoreTarget: 100,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute(
        user1Id: 'user-1',
        user2Id: 'user-2',
        name: 'Test',
      );

      final captured =
          verify(() => mockPairRepo.createPair(captureAny())).captured;
      final pair = captured.first as PairEntity;
      expect(pair.scoreTarget, 100);
    });

    test('should use custom scoreTarget when provided', () async {
      final createdPair = PairEntity(
        id: 'pair-1',
        user1Id: 'user-1',
        user2Id: 'user-2',
        createdAt: now,
        name: 'Test',
        scoreTarget: 200,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);
      when(() => mockUserRepo.updatePairId(any(), any()))
          .thenAnswer((_) async {});

      await useCase.execute(
        user1Id: 'user-1',
        user2Id: 'user-2',
        name: 'Test',
        scoreTarget: 200,
      );

      final captured =
          verify(() => mockPairRepo.createPair(captureAny())).captured;
      final pair = captured.first as PairEntity;
      expect(pair.scoreTarget, 200);
    });

    test('should propagate exception when createPair fails', () async {
      when(() => mockPairRepo.createPair(any()))
          .thenThrow(Exception('Create failed'));

      expect(
        () => useCase.execute(
          user1Id: 'user-1',
          user2Id: 'user-2',
          name: 'Test',
        ),
        throwsException,
      );
    });
  });
}
