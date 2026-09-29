class MAuthException implements Exception {
  final String code;
  MAuthException(this.code);

  @override
  String get message {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check and try again.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger one.';
      case 'operation-not-allowed':
        return 'This sign-in method is currently disabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      case 'credential-already-in-use':
        return 'This credential is already linked to another account.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'user-mismatch':
        return 'The provided credentials do not match the signed-in user.';
      case 'user-token-expired':
        return 'Your session has expired. Please log in again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}