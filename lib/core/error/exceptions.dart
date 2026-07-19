/// Base exception class for the application.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(message: $message, code: $code, details: $details)';
}

/// Thrown when a server/network error occurs.
class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

/// Thrown when a local caching/storage error occurs (e.g. Hive issues).
class CacheException extends AppException {
  const CacheException(super.message, {super.code, super.details});
}

/// Thrown when an authentication error occurs.
class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

/// Thrown for invalid input or validation errors.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}
