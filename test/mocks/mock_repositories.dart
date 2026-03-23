import 'package:mocktail/mocktail.dart';
import 'package:task_pair_app/domain/repositories/auth_repository.dart';
import 'package:task_pair_app/domain/repositories/user_repository.dart';
import 'package:task_pair_app/domain/repositories/pair_repository.dart';
import 'package:task_pair_app/domain/repositories/task_repository.dart';
import 'package:task_pair_app/domain/repositories/task_occurrence_repository.dart';
import 'package:task_pair_app/domain/repositories/task_execution_repository.dart';
import 'package:task_pair_app/domain/repositories/task_validation_repository.dart';
import 'package:task_pair_app/domain/repositories/task_recurrence_repository.dart';
import 'package:task_pair_app/domain/repositories/score_repository.dart';
import 'package:task_pair_app/domain/repositories/reward_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockPairRepository extends Mock implements PairRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockTaskOccurrenceRepository extends Mock
    implements TaskOccurrenceRepository {}

class MockTaskExecutionRepository extends Mock
    implements TaskExecutionRepository {}

class MockTaskValidationRepository extends Mock
    implements TaskValidationRepository {}

class MockTaskRecurrenceRepository extends Mock
    implements TaskRecurrenceRepository {}

class MockScoreRepository extends Mock implements ScoreRepository {}

class MockRewardRepository extends Mock implements RewardRepository {}
