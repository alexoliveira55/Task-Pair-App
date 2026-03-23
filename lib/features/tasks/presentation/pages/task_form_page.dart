import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/task_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/constants/app_constants.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormPage({super.key, this.taskId});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  String _recurrenceType = AppConstants.dailyRecurrence;
  final List<int> _selectedDays = [];
  bool _didLoadTask = false;

  bool get isEditing => widget.taskId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _loadTaskData(WidgetRef ref) {
    if (_didLoadTask || widget.taskId == null) return;
    final task = ref.read(taskByIdProvider(widget.taskId!));
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _pointsController.text = task.points.toString();
      _didLoadTask = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final taskState = ref.watch(taskNotifierProvider);

    // Load existing task data when editing
    _loadTaskData(ref);

    ref.listen(taskNotifierProvider, (_, next) {
      if (next.hasValue && !next.isLoading) {
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editTask : l10n.newTask),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: l10n.taskTitle,
                controller: _titleController,
                validator: (v) =>
                    v == null || v.isEmpty ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.taskDescription,
                controller: _descriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.points,
                controller: _pointsController,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.requiredField;
                  if (int.tryParse(v) == null) return l10n.invalidNumber;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(l10n.recurrence,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _recurrenceType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: [
                  AppConstants.dailyRecurrence,
                  AppConstants.weeklyRecurrence,
                  AppConstants.monthlyRecurrence,
                  AppConstants.onceRecurrence,
                ].map((type) {
                  final labels = {
                    AppConstants.dailyRecurrence: l10n.daily,
                    AppConstants.weeklyRecurrence: l10n.weekly,
                    AppConstants.monthlyRecurrence: l10n.monthly,
                    AppConstants.onceRecurrence: l10n.once,
                  };
                  return DropdownMenuItem(
                    value: type,
                    child: Text(labels[type] ?? type),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _recurrenceType = v);
                },
              ),
              if (_recurrenceType == AppConstants.weeklyRecurrence) ...[
                const SizedBox(height: 16),
                Text(l10n.daysOfWeek,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    l10n.mon,
                    l10n.tue,
                    l10n.wed,
                    l10n.thu,
                    l10n.fri,
                    l10n.sat,
                    l10n.sun
                  ].asMap().entries.map((e) {
                    final dayNum = e.key + 1;
                    final isSelected = _selectedDays.contains(dayNum);
                    return FilterChip(
                      label: Text(e.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayNum);
                          } else {
                            _selectedDays.remove(dayNum);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: isEditing ? l10n.updateTask : l10n.createTask,
                isLoading: taskState.isLoading,
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (isEditing) {
                    final existingTask =
                        ref.read(taskByIdProvider(widget.taskId!));
                    if (existingTask != null) {
                      await ref
                          .read(taskNotifierProvider.notifier)
                          .updateTask(existingTask.copyWith(
                            title: _titleController.text.trim(),
                            description:
                                _descriptionController.text.trim().isEmpty
                                    ? null
                                    : _descriptionController.text.trim(),
                            points: int.parse(_pointsController.text),
                          ));
                    }
                  } else {
                    await ref.read(taskNotifierProvider.notifier).createTask(
                          title: _titleController.text.trim(),
                          description:
                              _descriptionController.text.trim().isEmpty
                                  ? null
                                  : _descriptionController.text.trim(),
                          points: int.parse(_pointsController.text),
                          recurrenceType: _recurrenceType,
                          daysOfWeek:
                              _selectedDays.isEmpty ? null : _selectedDays,
                        );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
