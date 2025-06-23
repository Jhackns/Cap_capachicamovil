part of 'municipalidad_bloc.dart';

abstract class MunicipalidadState extends Equatable {
  const MunicipalidadState();

  @override
  List<Object> get props => [];
}

class MunicipalidadInitial extends MunicipalidadState {}

class MunicipalidadLoading extends MunicipalidadState {}

class MunicipalidadLoaded extends MunicipalidadState {
  final List<Municipalidad> municipalidades;

  const MunicipalidadLoaded(this.municipalidades);

  @override
  List<Object> get props => [municipalidades];
}

class MunicipalidadOperationSuccess extends MunicipalidadState {
  final String message;
  const MunicipalidadOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class MunicipalidadError extends MunicipalidadState {
  final String message;

  const MunicipalidadError(this.message);

  @override
  List<Object> get props => [message];
} 