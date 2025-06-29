part of 'municipalidad_bloc.dart';

abstract class MunicipalidadEvent extends Equatable {
  const MunicipalidadEvent();

  @override
  List<Object> get props => [];
}

class FetchMunicipalidades extends MunicipalidadEvent {}

class AddMunicipalidad extends MunicipalidadEvent {
  final Map<String, dynamic> municipalidadData;

  const AddMunicipalidad(this.municipalidadData);

  @override
  List<Object> get props => [municipalidadData];
}

class UpdateMunicipalidad extends MunicipalidadEvent {
  final int id;
  final Map<String, dynamic> municipalidadData;

  const UpdateMunicipalidad(this.id, this.municipalidadData);

  @override
  List<Object> get props => [id, municipalidadData];
}

class DeleteMunicipalidad extends MunicipalidadEvent {
  final int id;

  const DeleteMunicipalidad(this.id);

  @override
  List<Object> get props => [id];
} 