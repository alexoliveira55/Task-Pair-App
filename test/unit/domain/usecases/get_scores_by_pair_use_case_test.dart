import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';
import 'package:task_pair_app/domain/usecases/get_scores_by_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetScoresByPairUseCase useCase;
  late MockScoreRepository mockScoreRepo;

  setUp(() {
    mockScoreRepo = MockScoreRepository();
    useCase = GetScoresByPairUseCase(mockScoreRepo);
  });

  group('GetScoresByPairUseCase', () {
    test('should return scores for pair', () async {
      final scores = [
        ScoreEntity(
          id: 'score-1',
          pairId: 'pair-1',
          userId: 'user-1',
          totalPoints: 50,
          periodPoints: 20,
          updatedAt: DateTime(2024, 1, 15),
        ),
        ScoreEntity(
          id: 'score-2',
          pairId: 'pair-1',
          userId: 'user-2',
          totalPoints: 30,
          periodPoints: 10,
          updatedAt: DateTime(2024, 1, 15),
        ),
      ];

      when(() => mockScoreRepo.getScoresByPairId(any()))
          .thenAnswer((_) async => scores);

      final result = await useCase.execute('pair-1');

      expect(result.length, 2);
      verify(() => mockScoreRepo.getScoresByPairId('pair-1')).called(1);
    });

    test('should return empty list when no scores exist', () async {
      when(() => mockScoreRepo.getScoresByPairId(any()))
          .thenAnswer((_) async => []);

      final result = await useCase.execute('pair-1');

      expect(result, isEmpty);
    });
  });
}
