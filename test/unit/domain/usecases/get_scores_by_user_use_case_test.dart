import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/score_entity.dart';
import 'package:task_pair_app/domain/usecases/get_scores_by_user_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetScoresByUserUseCase useCase;
  late MockScoreRepository mockScoreRepo;

  setUp(() {
    mockScoreRepo = MockScoreRepository();
    useCase = GetScoresByUserUseCase(mockScoreRepo);
  });

  group('GetScoresByUserUseCase', () {
    test('should return scores for user', () async {
      final scores = [
        ScoreEntity(
          id: 'score-1',
          pairId: 'pair-1',
          userId: 'user-1',
          totalPoints: 50,
          periodPoints: 20,
          updatedAt: DateTime(2024, 1, 15),
        ),
      ];

      when(() => mockScoreRepo.getScoresByUserId(any()))
          .thenAnswer((_) async => scores);

      final result = await useCase.execute('user-1');

      expect(result.length, 1);
      verify(() => mockScoreRepo.getScoresByUserId('user-1')).called(1);
    });

    test('should return empty list when no scores', () async {
      when(() => mockScoreRepo.getScoresByUserId(any()))
          .thenAnswer((_) async => []);

      final result = await useCase.execute('user-1');

      expect(result, isEmpty);
    });
  });
}
