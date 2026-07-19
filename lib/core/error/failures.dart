import 'package:equatable/equatable.dart';

/// Base Failure class for the application, typically returned by repositories.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Represents a failure originating from a server/network operation.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Represents a failure originating from local caching operations.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Represents an authentication failure.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Represents a validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}
