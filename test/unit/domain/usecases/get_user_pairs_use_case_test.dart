import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/usecases/get_user_pairs_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetUserPairsUseCase useCase;
  late MockPairRepository mockPairRepo;

  final now = DateTime(2024, 1, 1);

  setUp(() {
    mockPairRepo = MockPairRepository();
    useCase = GetUserPairsUseCase(mockPairRepo);
  });

  group('GetUserPairsUseCase', () {
    test('should return pairs when user belongs to pairs', () async {
      final pairs = [
        PairEntity(
          id: 'pair-1',
          requesterId: 'user-1',
          executorId: 'user-2',
          createdAt: now,
          name: 'Pair as requester',
          scoreTarget: 100,
        ),
        PairEntity(
          id: 'pair-2',
          requesterId: 'user-3',
          executorId: 'user-1',
          createdAt: now,
          name: 'Pair as executor',
          scoreTarget: 150,
        ),
      ];

      when(() => mockPairRepo.watchPairsByUserId(any()))
          .thenAnswer((_) => Stream.value(pairs));

      final result = await useCase.execute('user-1');

      expect(result, hasLength(2));
      expect(result[0].id, 'pair-1');
      expect(result[1].id, 'pair-2');
      verify(() => mockPairRepo.watchPairsByUserId('user-1')).called(1);
    });

    test('should return empty list when user has no pairs', () async {
      when(() => mockPairRepo.watchPairsByUserId(any()))
          .thenAnswer((_) => Stream.value([]));

      final result = await useCase.execute('user-1');

      expect(result, isEmpty);
    });

    test('should watch a specific pair', () {
      final pair = PairEntity(
        id: 'pair-1',
        requesterId: 'user-1',
        executorId: 'user-2',
        createdAt: now,
        name: 'Test Pair',
        scoreTarget: 100,
      );

      when(() => mockPairRepo.watchPair(any()))
          .thenAnswer((_) => Stream.value(pair));

      final stream = useCase.watch('pair-1');

      expect(stream, emits(pair));
      verify(() => mockPairRepo.watchPair('pair-1')).called(1);
    });
  });
}
