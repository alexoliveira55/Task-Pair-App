import '../../core/constants/app_constants.dart';
import '../entities/task_occurrence_entity.dart';
import '../repositories/task_occurrence_repository.dart';

class GetPendingValidationsUseCase {
  final TaskOccurrenceRepository _occurrenceRepository;

  GetPendingValidationsUseCase(this._occurrenceRepository);

  Future<List<TaskOccurrenceEntity>> execute(String pairId) async {
    return _occurrenceRepository.getOccurrencesByStatus(
      pairId,
      AppConstants.executedStatus,
    );
  }
}
