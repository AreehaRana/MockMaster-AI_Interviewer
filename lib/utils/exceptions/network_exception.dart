class MNetworkException implements Exception {
  final String message;

  const MNetworkException([this.message = 'No internet connection. Please check your network and try again.']);

  factory MNetworkException.fromMessage(String message) {
    return MNetworkException(message);
  }

  @override
  String toString() => message;
}