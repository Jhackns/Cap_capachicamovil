part of 'reserva_bloc.dart';

abstract class ReservaState extends Equatable {
  const ReservaState();
  @override
  List<Object?> get props => [];
}

class ReservaInitial extends ReservaState {}

class ReservaLoading extends ReservaState { // General loading for lists etc.
  final String? message;
  const ReservaLoading({this.message});
   @override
  List<Object?> get props => [message];
}

class ReservaCreationInProgress extends ReservaState {}

class ReservaCreationSuccess extends ReservaState {
  final Reserva reserva;
  const ReservaCreationSuccess({required this.reserva});
  @override
  List<Object> get props => [reserva];
}

class ReservaCreationFailure extends ReservaState {
  final String message;
  const ReservaCreationFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class UserReservasLoading extends ReservaState {}

class UserReservasLoaded extends ReservaState {
  final List<Reserva> reservas;
  const UserReservasLoaded({required this.reservas});
  @override
  List<Object> get props => [reservas];
}

class ReservaOperationSuccess extends ReservaState { // For cancel, update etc.
  final String message;
  const ReservaOperationSuccess({required this.message});
   @override
  List<Object> get props => [message];
}

class ReservaOperationFailure extends ReservaState {
  final String message;
  const ReservaOperationFailure({required this.message});
   @override
  List<Object> get props => [message];
}

class ReservasError extends ReservaState { // General error for loading lists etc.
  final String message;
  const ReservasError({required this.message});
  @override
  List<Object> get props => [message];
}
