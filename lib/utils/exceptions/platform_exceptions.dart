class MPlatformException implements Exception {
  final String code;
  MPlatformException(this.code);

  @override
  String get message {
    switch (code) {
      case 'invalid-argument':
        return 'Invalid argument provided. Please check your input.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase.';
      case 'keychain-error':
        return 'Keychain error occurred. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'internal-error':
        return 'An internal error occurred. Please try again later.';
      case 'invalid-api-key':
        return 'Invalid API key provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}