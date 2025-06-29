import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/municipalidad.dart';
import '../../services/dashboard_service.dart';

part 'municipalidad_event.dart';
part 'municipalidad_state.dart';

class MunicipalidadBloc extends Bloc<MunicipalidadEvent, MunicipalidadState> {
  final DashboardService dashboardService;

  MunicipalidadBloc({required this.dashboardService})
      : super(MunicipalidadInitial()) {
    on<FetchMunicipalidades>(_onFetchMunicipalidades);
    on<AddMunicipalidad>(_onAddMunicipalidad);
    on<UpdateMunicipalidad>(_onUpdateMunicipalidad);
    on<DeleteMunicipalidad>(_onDeleteMunicipalidad);
  }

  Future<void> _onFetchMunicipalidades(
      FetchMunicipalidades event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      final municipalidades = await dashboardService.getMunicipalidades();
      emit(MunicipalidadLoaded(municipalidades));
    } catch (e) {
      emit(MunicipalidadError(e.toString()));
    }
  }

  Future<void> _onAddMunicipalidad(
      AddMunicipalidad event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      await dashboardService.createMunicipalidad(event.municipalidadData);
      emit(const MunicipalidadOperationSuccess('Municipalidad creada con éxito.'));
    } catch (e) {
      emit(MunicipalidadError(e.toString()));
    }
  }

  Future<void> _onUpdateMunicipalidad(
      UpdateMunicipalidad event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      await dashboardService.updateMunicipalidad(
          event.id, event.municipalidadData);
      emit(const MunicipalidadOperationSuccess('Municipalidad actualizada con éxito.'));
    } catch (e) {
      emit(MunicipalidadError(e.toString()));
    }
  }

  Future<void> _onDeleteMunicipalidad(
      DeleteMunicipalidad event, Emitter<MunicipalidadState> emit) async {
    emit(MunicipalidadLoading());
    try {
      await dashboardService.deleteMunicipalidad(event.id);
      emit(const MunicipalidadOperationSuccess('Municipalidad eliminada con éxito.'));
    } catch (e) {
      emit(MunicipalidadError(e.toString()));
    }
  }
} 