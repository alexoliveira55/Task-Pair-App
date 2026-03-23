import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/entities/reward_entity.dart';
import 'package:task_pair_app/domain/usecases/create_reward_use_case.dart';

import '../../../mocks/mock_repositories.dart';

void main() {
  late CreateRewardUseCase useCase;
  late MockRewardRepository mockRewardRepo;

  setUp(() {
    mockRewardRepo = MockRewardRepository();
    useCase = CreateRewardUseCase(mockRewardRepo);
  });

  setUpAll(() {
    registerFallbackValue(RewardEntity(
      id: '',
      pairId: '',
      title: '',
      requiredPoints: 0,
      isUnlocked: false,
    ));
  });

  group('CreateRewardUseCase', () {
    test('should create reward with isUnlocked=false', () async {
      final createdReward = RewardEntity(
        id: 'reward-1',
        pairId: 'pair-1',
        title: 'Movie Night',
        description: 'Watch a movie',
        requiredPoints: 50,
        isUnlocked: false,
      );

      when(() => mockRewardRepo.createReward(any()))
          .thenAnswer((_) async => createdReward);

      final result = await useCase.execute(
        pairId: 'pair-1',
        title: 'Movie Night',
        description: 'Watch a movie',
        requiredPoints: 50,
      );

      expect(result.id, 'reward-1');
      expect(result.isUnlocked, false);

      final captured =
          verify(() => mockRewardRepo.createReward(captureAny())).captured;
      final reward = captured.first as RewardEntity;
      expect(reward.isUnlocked, false);
      expect(reward.title, 'Movie Night');
      expect(reward.requiredPoints, 50);
    });

    test('should create reward without description', () async {
      final createdReward = RewardEntity(
        id: 'reward-1',
        pairId: 'pair-1',
        title: 'Dinner',
        requiredPoints: 100,
        isUnlocked: false,
      );

      when(() => mockRewardRepo.createReward(any()))
          .thenAnswer((_) async => createdReward);

      final result = await useCase.execute(
        pairId: 'pair-1',
        title: 'Dinner',
        requiredPoints: 100,
      );

      expect(result.description, isNull);
    });

    test('should propagate exception when createReward fails', () async {
      when(() => mockRewardRepo.createReward(any()))
          .thenThrow(Exception('Create failed'));

      expect(
        () => useCase.execute(
          pairId: 'pair-1',
          title: 'Reward',
          requiredPoints: 50,
        ),
        throwsException,
      );
    });
  });
}
