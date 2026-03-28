import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/usecases/create_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late CreatePairUseCase useCase;
  late MockPairRepository mockPairRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = CreatePairUseCase(mockPairRepo);
  });

  setUpAll(() {
    registerFallbackValue(PairEntity(
      id: '',
      requesterId: '',
      executorId: '',
      createdAt: DateTime.now(),
      name: '',
      scoreTarget: 0,
    ));
  });

  group('CreatePairUseCase', () {
    test('should create pair successfully', () async {
      final createdPair = PairEntity(
        id: 'pair-1',
        requesterId: 'user-1',
        executorId: 'user-2',
        createdAt: now,
        name: 'Test Pair',
        scoreTarget: 100,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);

      final result = await useCase.execute(
        requesterId: 'user-1',
        executorId: 'user-2',
        name: 'Test Pair',
      );

      expect(result.id, 'pair-1');
      expect(result.name, 'Test Pair');
      expect(result.requesterId, 'user-1');
      expect(result.executorId, 'user-2');
      verify(() => mockPairRepo.createPair(any())).called(1);
    });

    test('should use default scoreTarget of 100', () async {
      final createdPair = PairEntity(
        id: 'pair-1',
        requesterId: 'user-1',
        executorId: 'user-2',
        createdAt: now,
        name: 'Test',
        scoreTarget: 100,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);

      await useCase.execute(
        requesterId: 'user-1',
        executorId: 'user-2',
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
        requesterId: 'user-1',
        executorId: 'user-2',
        createdAt: now,
        name: 'Test',
        scoreTarget: 200,
      );

      when(() => mockPairRepo.createPair(any()))
          .thenAnswer((_) async => createdPair);

      await useCase.execute(
        requesterId: 'user-1',
        executorId: 'user-2',
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
          requesterId: 'user-1',
          executorId: 'user-2',
          name: 'Test',
        ),
        throwsException,
      );
    });
  });
}
