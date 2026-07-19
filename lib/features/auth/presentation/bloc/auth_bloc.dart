import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_inventory/features/auth/domain/usecases/auth_use_cases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthUseCases useCases;

  AuthBloc({required this.useCases}) : super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginRequestedEvent>(_onLoginRequested);
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final result = await useCases.getSession();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.unauthenticated)),
      (session) {
        if (session != null) {
          emit(state.copyWith(status: AuthStatus.authenticated, userSession: session));
        } else {
          emit(state.copyWith(status: AuthStatus.unauthenticated));
        }
      },
    );
  }

  Future<void> _onLoginRequested(LoginRequestedEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Email and password cannot be empty.'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
      return;
    }
    
    final result = await useCases.login(event.email, event.password);
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message));
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      },
      (success) async {
        final sessionResult = await useCases.getSession();
        sessionResult.fold(
          (failure) {
            emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message));
            emit(state.copyWith(status: AuthStatus.unauthenticated));
          },
          (session) {
            emit(state.copyWith(status: AuthStatus.authenticated, userSession: session, errorMessage: null));
          }
        );
      },
    );
  }

  Future<void> _onLogoutRequested(LogoutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await useCases.logout();
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: AuthStatus.unauthenticated, userSession: null)),
    );
  }
}
