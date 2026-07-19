import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? userSession;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.userSession,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    Map<String, dynamic>? userSession,
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
