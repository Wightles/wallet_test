class AppException implements Exception {
  const AppException({
    required this.code,
    this.message,
  });

  final String code;
  final String? message;

  @override
  String toString() => 'AppException($code: $message)';
}

class TransferSyncException extends AppException {
  const TransferSyncException({
    required super.code,
    super.message,
  });
}

class CancelException implements Exception {
  const CancelException();

  @override
  String toString() => 'Cancelled';
}
