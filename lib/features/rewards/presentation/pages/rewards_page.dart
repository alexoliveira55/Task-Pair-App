import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/rewards_provider.dart';
import '../../../../features/score/presentation/providers/score_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/themes/app_colors.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  bool _showCreateForm = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rewardsAsync = ref.watch(rewardsProvider);
    final rewardsState = ref.watch(rewardsNotifierProvider);
    final totalPoints = ref.watch(totalPairPointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _showCreateForm = !_showCreateForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showCreateForm)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Reward',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Title',
                        controller: _titleController,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Required Points',
                        controller: _pointsController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (int.tryParse(v) == null) return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Create Reward',
                        isLoading: rewardsState.isLoading,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          await ref
                              .read(rewardsNotifierProvider.notifier)
                              .createReward(
                                title: _titleController.text.trim(),
                                description:
                                    _descriptionController.text.trim().isEmpty
                                        ? null
                                        : _descriptionController.text.trim(),
                                requiredPoints:
                                    int.parse(_pointsController.text),
                              );
                          if (mounted) {
                            setState(() => _showCreateForm = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.stars, color: AppColors.scoreGold),
                const SizedBox(width: 8),
                Text('Current Points: $totalPoints'),
              ],
            ),
          ),
          Expanded(
            child: rewardsAsync.when(
              data: (rewards) {
                if (rewards.isEmpty) {
                  return const Center(child: Text('No rewards yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: rewards.length,
                  itemBuilder: (context, index) {
                    final reward = rewards[index];
                    final isEarned = totalPoints >= reward.requiredPoints;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: reward.isUnlocked
                              ? AppColors.scoreGold
                              : isEarned
                                  ? Colors.green
                                  : Colors.grey.shade300,
                          child: Icon(
                            reward.isUnlocked
                                ? Icons.lock_open
                                : Icons.lock_outline,
                            color: reward.isUnlocked
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        title: Text(reward.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reward.description != null)
                              Text(reward.description!),
                            Text('${reward.requiredPoints} points required'),
                          ],
                        ),
                        trailing: reward.isUnlocked
                            ? const Chip(
                                label: Text('Unlocked'),
                                backgroundColor: AppColors.scoreGold,
                              )
                            : isEarned
                                ? const Chip(label: Text('Earned!'))
                                : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}
