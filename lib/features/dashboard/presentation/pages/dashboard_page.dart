import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/thermometer_widget.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/pairs/presentation/providers/pair_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/responsive_layout.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final currentUserAsync = ref.watch(currentUserEntityProvider);
    final pairAsync = ref.watch(currentPairProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profile,
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: pairAsync.when(
        data: (pair) {
          if (pair == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noPairYet),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/pair-management'),
                    child: Text(l10n.createOrJoinPair),
                  ),
                ],
              ),
            );
          }
          return ResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  currentUserAsync.when(
                    data: (user) => Text(
                      l10n.welcomeUser(user?.displayName ?? 'User'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            pair.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          ThermometerWidget(
                            progress: dashboardData.thermometerProgress,
                            currentPoints: dashboardData.totalPoints,
                            targetPoints: pair.scoreTarget,
                            height: 180,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalTasks,
                          value: '${dashboardData.totalTasks}',
                          icon: Icons.task_alt,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: l10n.todayTasks,
                          value: '${dashboardData.todayCount}',
                          icon: Icons.today,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: l10n.statusPending,
                          value: '${dashboardData.pendingCount}',
                          icon: Icons.pending_outlined,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.quickActions,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.add_task),
                        label: Text(l10n.createTask),
                        onPressed: () => context.push('/tasks/new'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.list),
                        label: Text(l10n.tasks),
                        onPressed: () => context.push('/tasks'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.star),
                        label: Text(l10n.rewards),
                        onPressed: () => context.push('/rewards'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.bar_chart),
                        label: Text(l10n.reports),
                        onPressed: () => context.push('/reports'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.people),
                        label: Text(l10n.pairs),
                        onPressed: () => context.push('/pair-management'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.person),
                        label: Text(l10n.profile),
                        onPressed: () => context.push('/profile'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
