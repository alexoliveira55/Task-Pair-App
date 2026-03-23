import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/reward_entity.dart';
import 'package:task_pair_app/domain/usecases/get_rewards_by_pair_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late GetRewardsByPairUseCase useCase;
  late MockRewardRepository mockRewardRepo;

  setUp(() {
    mockRewardRepo = MockRewardRepository();
    useCase = GetRewardsByPairUseCase(mockRewardRepo);
  });

  group('GetRewardsByPairUseCase', () {
    test('should return rewards for pair', () async {
      final rewards = [
        RewardEntity(
          id: 'reward-1',
          pairId: 'pair-1',
          title: 'Movie Night',
          requiredPoints: 50,
          isUnlocked: false,
        ),
        RewardEntity(
          id: 'reward-2',
          pairId: 'pair-1',
          title: 'Dinner',
          requiredPoints: 100,
          isUnlocked: true,
          unlockedAt: DateTime(2024, 2, 1),
        ),
      ];

      when(() => mockRewardRepo.getRewardsByPairId(any()))
          .thenAnswer((_) async => rewards);

      final result = await useCase.execute('pair-1');

      expect(result.length, 2);
      verify(() => mockRewardRepo.getRewardsByPairId('pair-1')).called(1);
    });

    test('should return empty list when no rewards', () async {
      when(() => mockRewardRepo.getRewardsByPairId(any()))
          .thenAnswer((_) async => []);

      final result = await useCase.execute('pair-1');

      expect(result, isEmpty);
    });
  });
}
