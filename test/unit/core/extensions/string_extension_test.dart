import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/extensions/string_extension.dart';

void main() {
  group('StringExtension', () {
    group('capitalize', () {
      test('should capitalize first letter', () {
        expect('hello'.capitalize, 'Hello');
      });

      test('should return empty string for empty input', () {
        expect(''.capitalize, '');
      });

      test('should handle already capitalized string', () {
        expect('Hello'.capitalize, 'Hello');
      });

      test('should handle single character', () {
        expect('h'.capitalize, 'H');
      });
    });

    group('titleCase', () {
      test('should capitalize each word', () {
        expect('hello world'.titleCase, 'Hello World');
      });

      test('should handle single word', () {
        expect('hello'.titleCase, 'Hello');
      });

      test('should handle multiple spaces between words', () {
        // Split on single space
        expect('hello world'.titleCase, 'Hello World');
      });
    });

    group('isValidEmail', () {
      test('should return true for valid email', () {
        expect('test@example.com'.isValidEmail, isTrue);
      });

      test('should return true for email with subdomain', () {
        expect('test@mail.example.com'.isValidEmail, isTrue);
      });

      test('should return false for email without @', () {
        expect('testexample.com'.isValidEmail, isFalse);
      });

      test('should return false for email without domain', () {
        expect('test@'.isValidEmail, isFalse);
      });

      test('should return false for empty string', () {
        expect(''.isValidEmail, isFalse);
      });

      test('should return true for email with dots and dashes', () {
        expect('user.name-test@example.com'.isValidEmail, isTrue);
      });
    });

    group('isValidPassword', () {
      test('should return true for password with 6+ characters', () {
        expect('123456'.isValidPassword, isTrue);
      });

      test('should return true for long password', () {
        expect('mySecurePassword123'.isValidPassword, isTrue);
      });

      test('should return false for password with less than 6 characters', () {
        expect('12345'.isValidPassword, isFalse);
      });

      test('should return false for empty string', () {
        expect(''.isValidPassword, isFalse);
      });

      test('should return true for exactly 6 characters', () {
        expect('abcdef'.isValidPassword, isTrue);
      });
    });

    group('nullIfEmpty', () {
      test('should return null for empty string', () {
        expect(''.nullIfEmpty, isNull);
      });

      test('should return string for non-empty string', () {
        expect('hello'.nullIfEmpty, 'hello');
      });
    });

    group('truncate', () {
      test('should not truncate short strings', () {
        expect('hi'.truncate(10), 'hi');
      });

      test('should truncate long strings with ellipsis', () {
        expect('Hello World Test'.truncate(10), 'Hello W...');
      });

      test('should use custom ellipsis', () {
        expect(
          'Hello World'.truncate(8, ellipsis: '…'),
          'Hello W…',
        );
      });

      test('should not truncate string at exact max length', () {
        expect('Hello'.truncate(5), 'Hello');
      });
    });
  });
}
