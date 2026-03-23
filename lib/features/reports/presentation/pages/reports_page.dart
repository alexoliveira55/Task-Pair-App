import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reports_provider.dart';
import '../../../../shared/themes/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final reportData = ref.watch(reportsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.statistics,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ReportCard(
                    label: l10n.statusExecuted,
                    value: '${reportData.completedOccurrences.length}',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReportCard(
                    label: l10n.statusPending,
                    value: '${reportData.pendingOccurrences.length}',
                    color: Colors.orange,
                    icon: Icons.pending,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReportCard(
                    label: l10n.statusMissed,
                    value: '${reportData.missedOccurrences.length}',
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.completionRate,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: reportData.completionRate,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(reportData.completionRate * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.score, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...reportData.scores.map((score) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                        l10n.userLabel('${score.userId.substring(0, 6)}...')),
                    subtitle: Text(l10n.totalAndPeriodPoints(
                        score.totalPoints, score.periodPoints)),
                    trailing: Text(
                      '+${score.totalPoints}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),
            if (reportData.scores.isEmpty) Center(child: Text(l10n.noData)),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _ReportCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
