import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/validation_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/constants/app_constants.dart';

class ValidationPage extends ConsumerStatefulWidget {
  final String executionId;

  const ValidationPage({super.key, required this.executionId});

  @override
  ConsumerState<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends ConsumerState<ValidationPage> {
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validationState = ref.watch(validationNotifierProvider);

    ref.listen(validationNotifierProvider, (_, next) {
      if (next.hasValue && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Validation submitted!')),
        );
        context.pop();
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Validate Task')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Task Execution',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Execution ID: ${widget.executionId}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Feedback (optional)',
              controller: _feedbackController,
              maxLines: 4,
              hint: 'Add any feedback...',
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Approve',
              icon: Icons.check_circle,
              color: Colors.green,
              isLoading: validationState.isLoading,
              onPressed: () async {
                final pair = ref.read(currentPairProvider).value;
                if (pair == null) return;
                await ref.read(validationNotifierProvider.notifier).validate(
                      executionId: widget.executionId,
                      occurrenceId: '',
                      isApproved: true,
                      feedback: _feedbackController.text.trim().isEmpty
                          ? null
                          : _feedbackController.text.trim(),
                      pairId: pair.id,
                      points: AppConstants.defaultTaskPoints,
                      executedBy: '',
                    );
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Reject',
              icon: Icons.cancel,
              color: Colors.red,
              isOutlined: true,
              isLoading: validationState.isLoading,
              onPressed: () async {
                final pair = ref.read(currentPairProvider).value;
                if (pair == null) return;
                await ref.read(validationNotifierProvider.notifier).validate(
                      executionId: widget.executionId,
                      occurrenceId: '',
                      isApproved: false,
                      feedback: _feedbackController.text.trim().isEmpty
                          ? null
                          : _feedbackController.text.trim(),
                      pairId: pair.id,
                      points: 0,
                      executedBy: '',
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
