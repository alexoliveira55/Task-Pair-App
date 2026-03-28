import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'app_exception.dart';

/// Maps [AuthException] Firebase error codes to localized user-friendly messages.
String mapAuthErrorToMessage(Object error, AppLocalizations l10n) {
  if (error is AuthException) {
    switch (error.code) {
      case 'user-not-found':
        return l10n.userNotFound;
      case 'wrong-password':
        return l10n.wrongPassword;
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'user-disabled':
        return l10n.userDisabled;
      case 'too-many-requests':
        return l10n.tooManyRequests;
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return l10n.invalidCredentials;
      case 'email-already-in-use':
        return l10n.emailInUse;
      case 'weak-password':
        return l10n.weakPassword;
      case 'network-request-failed':
        return l10n.networkError;
      default:
        return l10n.unknownAuthError;
    }
  }
  return l10n.unknownAuthError;
}
