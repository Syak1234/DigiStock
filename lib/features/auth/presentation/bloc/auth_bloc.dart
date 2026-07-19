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
    try {
      final session = await useCases.getSession();
      if (session != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, userSession: session));
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(LoginRequestedEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Email and password cannot be empty.'));
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }
      
      await useCases.login(event.email, event.password);
      final session = await useCases.getSession();
      
      emit(state.copyWith(status: AuthStatus.authenticated, userSession: session, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: 'Login failed: ${e.toString()}'));
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequestedEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await useCases.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated, userSession: null));
  }
}
