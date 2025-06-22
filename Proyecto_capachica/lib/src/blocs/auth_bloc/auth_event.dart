part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthAppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String nombre;
  final String email;
  final String password;
  final UserRole rol; // Or determine this server-side / default

  const RegisterRequested({
    required this.nombre,
    required this.email,
    required this.password,
    this.rol = UserRole.turista, // Default role
  });

  @override
  List<Object> get props => [nombre, email, password, rol];
}

class LogoutRequested extends AuthEvent {}
