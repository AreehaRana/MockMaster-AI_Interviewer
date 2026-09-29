class MFirebaseException implements Exception {
  final String code;
  MFirebaseException(this.code);

  @override
  String get message {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'not-found':
        return 'The requested document was not found.';
      case 'already-exists':
        return 'This document already exists.';
      case 'cancelled':
        return 'The operation was cancelled.';
      case 'data-loss':
        return 'Unrecoverable data loss or corruption occurred.';
      case 'deadline-exceeded':
        return 'The operation took too long to complete. Please try again.';
      case 'failed-precondition':
        return 'Operation rejected due to system state. Please try again.';
      case 'internal':
        return 'An internal error occurred. Please try again later.';
      case 'invalid-argument':
        return 'Invalid argument provided.';
      case 'resource-exhausted':
        return 'Quota exceeded or rate limit reached. Please try again later.';
      case 'unauthenticated':
        return 'You are not authenticated. Please log in and try again.';
      case 'unimplemented':
        return 'This operation is not implemented or supported.';
      case 'unknown':
        return 'An unknown error occurred. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}