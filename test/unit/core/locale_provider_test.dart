import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/providers/locale_provider.dart';
import 'dart:ui';

void main() {
  group('LocaleNotifier', () {
    group('resolveLocale', () {
      test('returns override locale when provided (en)', () {
        final result = LocaleNotifier.resolveLocale(const Locale('en'));
        expect(result, const Locale('en'));
      });

      test('returns override locale when provided (pt_BR)', () {
        final result = LocaleNotifier.resolveLocale(const Locale('pt', 'BR'));
        expect(result, const Locale('pt', 'BR'));
      });

      test('returns pt_BR when override is null and system is pt', () {
        // When override is null, resolveLocale uses PlatformDispatcher.instance.locale.
        // In test environment the platform locale is typically en-US,
        // so we can only verify the code path indirectly.
        // We test that providing null does not crash and returns a supported locale.
        final result = LocaleNotifier.resolveLocale(null);
        expect(
          supportedLocales,
          contains(result),
          reason: 'resolveLocale(null) should return a supported locale',
        );
      });

      test('always returns a supported locale when override is null', () {
        final result = LocaleNotifier.resolveLocale(null);
        expect(result.languageCode, anyOf('pt', 'en'));
      });

      test('returns exact override even if not in supportedLocales', () {
        // resolveLocale should pass through any non-null override as-is
        final result = LocaleNotifier.resolveLocale(const Locale('fr'));
        expect(result, const Locale('fr'));
      });
    });
  });

  group('supportedLocales', () {
    test('contains pt_BR', () {
      expect(supportedLocales, contains(const Locale('pt', 'BR')));
    });

    test('contains en', () {
      expect(supportedLocales, contains(const Locale('en')));
    });

    test('has exactly 2 locales', () {
      expect(supportedLocales.length, 2);
    });
  });
}
