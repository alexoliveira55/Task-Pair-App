import '../../../domain/entities/task_recurrence_entity.dart';
import '../../../domain/entities/task_occurrence_entity.dart';
import '../../../domain/repositories/task_occurrence_repository.dart';
import '../../../core/constants/app_constants.dart';

class GenerateOccurrencesUseCase {
  final TaskOccurrenceRepository _occurrenceRepository;

  GenerateOccurrencesUseCase(this._occurrenceRepository);

  Future<List<TaskOccurrenceEntity>> execute({
    required TaskRecurrenceEntity recurrence,
    required String pairId,
    required String assignedTo,
    DateTime? from,
    DateTime? to,
  }) async {
    final start = from ?? recurrence.startDate;
    final end = to ?? (recurrence.endDate ?? start.add(const Duration(days: 30)));

    final List<DateTime> dueDates = [];

    switch (recurrence.type) {
      case AppConstants.dailyRecurrence:
        var current = start;
        while (!current.isAfter(end)) {
          dueDates.add(current);
          current = current.add(const Duration(days: 1));
        }
        break;
      case AppConstants.weeklyRecurrence:
        final days = recurrence.daysOfWeek ?? [1, 2, 3, 4, 5];
        var current = start;
        while (!current.isAfter(end)) {
          if (days.contains(current.weekday)) {
            dueDates.add(current);
          }
          current = current.add(const Duration(days: 1));
        }
        break;
      case AppConstants.monthlyRecurrence:
        final dayOfMonth = recurrence.dayOfMonth ?? 1;
        var current = DateTime(start.year, start.month, dayOfMonth);
        while (!current.isAfter(end)) {
          if (!current.isBefore(start)) dueDates.add(current);
          current = DateTime(current.year, current.month + 1, dayOfMonth);
        }
        break;
      case AppConstants.onceRecurrence:
        dueDates.add(start);
        break;
    }

    final occurrences = <TaskOccurrenceEntity>[];
    for (final dueDate in dueDates) {
      final occurrence = await _occurrenceRepository.createOccurrence(
        TaskOccurrenceEntity(
          id: '',
          taskId: recurrence.taskId,
          pairId: pairId,
          dueDate: dueDate,
          status: AppConstants.pendingStatus,
          assignedTo: assignedTo,
        ),
      );
      occurrences.add(occurrence);
    }

    return occurrences;
  }
}
