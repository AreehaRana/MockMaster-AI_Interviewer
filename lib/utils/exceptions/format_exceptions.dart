class MFormatException implements Exception {
  final String message;

  const MFormatException([this.message = 'An unexpected format error occurred.']);

  factory MFormatException.fromMessage(String message) {
    return MFormatException(message);
  }

  @override
  String toString() => message;
}