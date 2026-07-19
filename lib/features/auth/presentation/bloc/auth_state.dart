import 'package:equatable/equatable.dart';
import 'package:product_inventory/features/auth/domain/entities/user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final User? userSession;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.userSession,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    User? userSession,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      userSession: userSession ?? this.userSession,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, userSession];
}
