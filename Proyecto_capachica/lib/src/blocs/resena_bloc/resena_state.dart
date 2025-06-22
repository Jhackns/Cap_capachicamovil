part of 'resena_bloc.dart';

abstract class ResenaState extends Equatable {
  const ResenaState();
  @override
  List<Object?> get props => [];
}

class ResenaInitial extends ResenaState {}

class ResenaLoading extends ResenaState {}

class ResenaSubmissionInProgress extends ResenaState {}

class ResenaSubmissionSuccess extends ResenaState {
  final Resena resena;
  const ResenaSubmissionSuccess({required this.resena});
  @override
  List<Object> get props => [resena];
}

class ResenaSubmissionFailure extends ResenaState {
  final String message;
  const ResenaSubmissionFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class ResenasLoaded extends ResenaState {
  final List<Resena> resenas;
  const ResenasLoaded({required this.resenas});
  @override
  List<Object> get props => [resenas];
}

class ResenasError extends ResenaState {
  final String message;
  const ResenasError({required this.message});
  @override
  List<Object> get props => [message];
}
