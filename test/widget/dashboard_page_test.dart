import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/domain/entities/pair_entity.dart';
import 'package:task_pair_app/domain/entities/user_entity.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:task_pair_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:task_pair_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:task_pair_app/features/pairs/presentation/providers/pair_provider.dart';

void main() {
  final testPair = PairEntity(
    id: 'pair-1',
    requesterId: 'user-1',
    executorId: 'user-2',
    createdAt: DateTime(2024, 1, 1),
    name: 'Test Pair',
    scoreTarget: 100,
  );

  final testUser = UserEntity(
    id: 'user-1',
    email: 'test@example.com',
    displayName: 'Tester',
    createdAt: DateTime(2024, 1, 1),
  );

  Widget createDashboard({PairEntity? pair, UserEntity? user}) {
    return ProviderScope(
      overrides: [
        currentPairProvider.overrideWithValue(pair ?? testPair),
        currentUserEntityProvider.overrideWith(
          (ref) => Stream.value(user ?? testUser),
        ),
        dashboardDataProvider.overrideWithValue(
          DashboardData(
            pair: pair ?? testPair,
            scores: [],
            totalPoints: 50,
            thermometerProgress: 0.5,
            totalTasks: 5,
            pendingCount: 2,
            todayCount: 1,
          ),
        ),
        authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier()),
      ],
      child: const MaterialApp(
        home: DashboardPage(),
      ),
    );
  }

  group('DashboardPage', () {
    testWidgets('should render Dashboard appbar title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pump();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('should render sign out button icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pump();

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('should render profile button icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDashboard());
      await tester.pump();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('should show no pair message when pair is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          currentPairProvider.overrideWithValue(null),
          currentUserEntityProvider.overrideWith(
            (ref) => Stream.value(testUser),
          ),
          authNotifierProvider.overrideWith((ref) => _FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('No pair yet'), findsOneWidget);
      expect(find.text('Create or Join a Pair'), findsOneWidget);
    });
  });
}

class _FakeAuthNotifier extends StateNotifier<AsyncValue<void>>
    implements AuthNotifier {
  _FakeAuthNotifier() : super(const AsyncValue.data(null));

  @override
  Future<void> signIn(
      {required String email, required String password}) async {}

  @override
  Future<void> register(
      {required String email,
      required String password,
      required String displayName}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
