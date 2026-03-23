import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_pair_app/features/auth/presentation/pages/login_page.dart';
import 'package:task_pair_app/features/auth/presentation/providers/auth_provider.dart';

void main() {
  Widget createLoginPage({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) {
          return _FakeAuthNotifier();
        }),
        ...overrides,
      ],
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('should render email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should render Sign In button', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should render app title', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      expect(find.text('Task Pair App'), findsOneWidget);
    });

    testWidgets('should render register link', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      expect(find.text("Don't have an account? Register"), findsOneWidget);
    });

    testWidgets('should show validation error for empty email',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Type valid email
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show validation error for short password',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Minimum 6 characters'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should render password visibility toggle icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      // Password field has a visibility toggle icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should have task_alt icon', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });
  });
}

/// A fake AuthNotifier that does nothing - for widget test rendering.
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
