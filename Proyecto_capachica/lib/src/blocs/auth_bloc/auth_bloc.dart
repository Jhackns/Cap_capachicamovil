import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// It's good practice to import models via a barrel file or directly if not too many
// Placeholder for AuthService, actual import path might differ

import '../../models/usuario/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Placeholder for AuthService, will be injected
  // final AuthService _authService;

  AuthBloc(/*this._authService*/) : super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAppStarted(AuthAppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // In a real app, check for existing token here using _authService
    // For now, simulate no token found
    // final bool hasToken = await _authService.hasToken();
    // if (hasToken) {
    //   try {
    //     // final user = await _authService.getCurrentUser(); // Fetch user details
    //     // emit(AuthAuthenticated(user: user));
    //     // Simulate fetching user
    //     await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    //     const mockUser = User(id: 'mock_id_on_start', nombre: 'Mock User', email: 'mock@example.com', rol: UserRole.turista);
    //     emit(AuthAuthenticated(user: mockUser));
    //   } catch (e) {
    //     // await _authService.deleteToken(); // Clear invalid token
    //     emit(AuthUnauthenticated());
    //   }
    // } else {
    //   emit(AuthUnauthenticated());
    // }
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate check
    emit(AuthUnauthenticated()); // Default to unauthenticated for now
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // In a real app: final user = await _authService.login(event.email, event.password);
      // In a real app: await _authService.saveToken('some_mock_token');
      if (event.email == 'test@example.com' && event.password == 'password') {
        var user = User(id: '1', nombre: 'Test User', email: event.email, rol: UserRole.turista);
        emit(AuthAuthenticated(user: user));
      } else if (event.email == 'admin@example.com' && event.password == 'adminpass') {
        var user = User(id: '0', nombre: 'Admin User', email: event.email, rol: UserRole.administrador);
        emit(AuthAuthenticated(user: user));
      }
      else {
        emit(const AuthFailure(message: 'Invalid credentials'));
      }
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      // In a real app: final user = await _authService.register(event.nombre, event.email, event.password, event.rol);
      // In a real app: await _authService.saveToken('some_mock_token_for_new_user');
      var user = User(id: '2', nombre: event.nombre, email: event.email, rol: event.rol);
      emit(AuthAuthenticated(user: user)); // Auto-login after registration
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    // In a real app: await _authService.deleteToken();
    // In a real app: await _authService.logout(); // any server-side logout
    await Future.delayed(const Duration(milliseconds: 500));
    emit(AuthUnauthenticated());
  }
}
