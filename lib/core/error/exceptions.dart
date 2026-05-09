class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() =>
      message; // Override to show message, not "Instance of..."
}
