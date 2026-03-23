import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ARB completeness', () {
    late Map<String, dynamic> ptBrArb;
    late Map<String, dynamic> enArb;

    setUp(() {
      final ptBrFile = File('lib/l10n/app_pt_BR.arb');
      final enFile = File('lib/l10n/app_en.arb');

      expect(ptBrFile.existsSync(), isTrue, reason: 'app_pt_BR.arb must exist');
      expect(enFile.existsSync(), isTrue, reason: 'app_en.arb must exist');

      ptBrArb = jsonDecode(ptBrFile.readAsStringSync()) as Map<String, dynamic>;
      enArb = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('en.arb has all non-metadata keys from pt_BR.arb', () {
      final ptKeys = ptBrArb.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInEn = ptKeys.difference(enKeys);
      expect(missingInEn, isEmpty,
          reason: 'Missing keys in en.arb: $missingInEn');
    });

    test('pt_BR.arb has all non-metadata keys from en.arb', () {
      final ptKeys = ptBrArb.keys.where((k) => !k.startsWith('@')).toSet();
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();

      final missingInPt = enKeys.difference(ptKeys);
      expect(missingInPt, isEmpty,
          reason: 'Missing keys in pt_BR.arb: $missingInPt');
    });

    test('no empty translation values in pt_BR.arb', () {
      final emptyKeys = ptBrArb.entries
          .where((e) =>
              !e.key.startsWith('@') &&
              e.value is String &&
              (e.value as String).isEmpty)
          .map((e) => e.key)
          .toList();
      expect(emptyKeys, isEmpty,
          reason: 'Empty values in pt_BR.arb: $emptyKeys');
    });

    test('no empty translation values in en.arb', () {
      final emptyKeys = enArb.entries
          .where((e) =>
              !e.key.startsWith('@') &&
              e.value is String &&
              (e.value as String).isEmpty)
          .map((e) => e.key)
          .toList();
      expect(emptyKeys, isEmpty, reason: 'Empty values in en.arb: $emptyKeys');
    });

    test('all ARB files have valid JSON', () {
      // If setUp succeeded, JSON is valid.
      // Extra check: keys should not be empty.
      expect(ptBrArb.keys.length, greaterThan(1));
      expect(enArb.keys.length, greaterThan(1));
    });

    test('template file (pt_BR) has metadata for translation keys', () {
      final translationKeys = ptBrArb.keys
          .where((k) => !k.startsWith('@') && k != '@@locale')
          .toSet();
      final metadataKeys = ptBrArb.keys
          .where((k) => k.startsWith('@') && k != '@@locale')
          .toSet();

      // Each metadata key corresponds to a translation key
      for (final meta in metadataKeys) {
        final baseKey = meta.substring(1); // remove leading @
        expect(translationKeys, contains(baseKey),
            reason: 'Metadata key $meta has no corresponding translation key');
      }
    });
  });
}
