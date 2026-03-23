import 'package:flutter_test/flutter_test.dart';
import 'package:task_pair_app/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName should be Task Pair App', () {
      expect(AppConstants.appName, 'Task Pair App');
    });

    test('defaultScoreTarget should be 100', () {
      expect(AppConstants.defaultScoreTarget, 100);
    });

    test('defaultTaskPoints should be 10', () {
      expect(AppConstants.defaultTaskPoints, 10);
    });

    group('occurrence statuses', () {
      test('pendingStatus should be pending', () {
        expect(AppConstants.pendingStatus, 'pending');
      });

      test('executedStatus should be executed', () {
        expect(AppConstants.executedStatus, 'executed');
      });

      test('validatedStatus should be validated', () {
        expect(AppConstants.validatedStatus, 'validated');
      });

      test('missedStatus should be missed', () {
        expect(AppConstants.missedStatus, 'missed');
      });
    });

    group('validation statuses', () {
      test('approvedStatus should be approved', () {
        expect(AppConstants.approvedStatus, 'approved');
      });

      test('rejectedStatus should be rejected', () {
        expect(AppConstants.rejectedStatus, 'rejected');
      });
    });

    group('recurrence types', () {
      test('dailyRecurrence should be daily', () {
        expect(AppConstants.dailyRecurrence, 'daily');
      });

      test('weeklyRecurrence should be weekly', () {
        expect(AppConstants.weeklyRecurrence, 'weekly');
      });

      test('monthlyRecurrence should be monthly', () {
        expect(AppConstants.monthlyRecurrence, 'monthly');
      });

      test('onceRecurrence should be once', () {
        expect(AppConstants.onceRecurrence, 'once');
      });
    });

    group('invite statuses', () {
      test('inviteStatusPending should be pending', () {
        expect(AppConstants.inviteStatusPending, 'pending');
      });

      test('inviteStatusAccepted should be accepted', () {
        expect(AppConstants.inviteStatusAccepted, 'accepted');
      });

      test('inviteStatusDeclined should be declined', () {
        expect(AppConstants.inviteStatusDeclined, 'declined');
      });
    });
  });
}
