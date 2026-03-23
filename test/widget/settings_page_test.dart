import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:task_pair_app/features/settings/presentation/pages/settings_page.dart';

Widget createTestWidget({Locale locale = const Locale('en')}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsPage(),
    ),
  );
}

void main() {
  group('SettingsPage', () {
    testWidgets('renders in English with language selector', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Settings'), findsOneWidget);
      // Language section header
      expect(find.text('Language'), findsOneWidget);
      // System default option
      expect(find.text('System default'), findsOneWidget);
      // Three radio options: System Default, Portuguese, English
      expect(find.byType(RadioListTile<Locale?>), findsNWidgets(3));
    });

    testWidgets('renders in Portuguese when locale is pt_BR', (tester) async {
      await tester
          .pumpWidget(createTestWidget(locale: const Locale('pt', 'BR')));
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);
      expect(find.text('Padrão do sistema'), findsOneWidget);
    });

    testWidgets('system default radio is selected by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The first RadioListTile (System Default) should be selected
      // because localeProvider initial state is null
      final systemDefaultTile = tester.widget<RadioListTile<Locale?>>(
        find.byType(RadioListTile<Locale?>).first,
      );
      expect(systemDefaultTile.value, isNull);
      expect(systemDefaultTile.groupValue, isNull);
    });

    testWidgets('shows Portuguese subtitle text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Português (Brasil)'), findsOneWidget);
      // 'English' appears as both the radio title and subtitle text
      expect(find.text('English'), findsNWidgets(2));
    });
  });
}
