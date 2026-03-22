import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/pairs/presentation/pages/pair_management_page.dart';
import '../features/pairs/presentation/pages/invite_page.dart';
import '../features/tasks/presentation/pages/task_list_page.dart';
import '../features/tasks/presentation/pages/task_form_page.dart';
import '../features/execution/presentation/pages/task_execution_page.dart';
import '../features/validation/presentation/pages/validation_page.dart';
import '../features/score/presentation/pages/score_page.dart';
import '../features/rewards/presentation/pages/rewards_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/pair-management',
        builder: (context, state) => const PairManagementPage(),
      ),
      GoRoute(
        path: '/invite',
        builder: (context, state) => const InvitePage(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListPage(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskFormPage(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskFormPage(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/tasks/:id/edit',
        builder: (context, state) {
          final taskId = state.pathParameters['id']!;
          return TaskFormPage(taskId: taskId);
        },
      ),
      GoRoute(
        path: '/execute/:occurrenceId',
        builder: (context, state) {
          final occurrenceId = state.pathParameters['occurrenceId']!;
          return TaskExecutionPage(occurrenceId: occurrenceId);
        },
      ),
      GoRoute(
        path: '/validate/:executionId',
        builder: (context, state) {
          final executionId = state.pathParameters['executionId']!;
          return ValidationPage(executionId: executionId);
        },
      ),
      GoRoute(
        path: '/score',
        builder: (context, state) => const ScorePage(),
      ),
      GoRoute(
        path: '/rewards',
        builder: (context, state) => const RewardsPage(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
