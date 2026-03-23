import '../entities/task_occurrence_entity.dart';
import '../repositories/task_occurrence_repository.dart';

class GetPendingExecutionsUseCase {
  final TaskOccurrenceRepository _occurrenceRepository;

  GetPendingExecutionsUseCase(this._occurrenceRepository);

  Future<List<TaskOccurrenceEntity>> execute(String pairId) async {
    return _occurrenceRepository.getPendingOccurrences(pairId);
  }

  Stream<List<TaskOccurrenceEntity>> watch(String pairId) {
    return _occurrenceRepository.watchOccurrencesByPairId(pairId);
  }
}
