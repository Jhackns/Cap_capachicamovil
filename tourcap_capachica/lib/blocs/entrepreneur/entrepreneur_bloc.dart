import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/entrepreneur.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'entrepreneur_event.dart';
import 'entrepreneur_state.dart';

class EntrepreneurBloc extends Bloc<EntrepreneurEvent, EntrepreneurState> {
  final ApiService _apiService = ApiService();
  Map<int, Entrepreneur> _entrepreneurCache = {};

  EntrepreneurBloc() : super(EntrepreneurInitial()) {
    on<FetchEntrepreneurs>(_onFetchEntrepreneurs);
    on<GetEntrepreneurById>(_onGetEntrepreneurById);
    on<AddEntrepreneur>(_onAddEntrepreneur);
    on<UpdateEntrepreneur>(_onUpdateEntrepreneur);
    on<DeleteEntrepreneur>(_onDeleteEntrepreneur);
    on<ClearEntrepreneurError>(_onClearError);
  }

  Future<void> _onFetchEntrepreneurs(
    FetchEntrepreneurs event,
    Emitter<EntrepreneurState> emit,
  ) async {
    emit(EntrepreneurLoading());
    try {
      final data = await _apiService.get(ApiConfig.getEntrepreneursUrl());
      if (data != null) {
        final entrepreneurs = (data as List)
            .map((item) => Entrepreneur.fromJson(item))
            .toList();
        _updateCache(entrepreneurs);
        emit(EntrepreneurLoaded(entrepreneurs));
      } else {
        emit(EntrepreneurLoaded([]));
      }
    } catch (e) {
      emit(EntrepreneurError(e.toString()));
    }
  }

  Future<void> _onGetEntrepreneurById(
    GetEntrepreneurById event,
    Emitter<EntrepreneurState> emit,
  ) async {
    if (_entrepreneurCache.containsKey(event.id)) {
      emit(EntrepreneurDetailLoaded(_entrepreneurCache[event.id]!));
      return;
    }

    try {
      final data = await _apiService.get(
        ApiConfig.getEntrepreneurByIdUrl(event.id),
        requiresAuth: true,
      );
      if (data != null) {
        final entrepreneur = Entrepreneur.fromJson(data);
        _entrepreneurCache[entrepreneur.id] = entrepreneur;
        emit(EntrepreneurDetailLoaded(entrepreneur));
      } else {
        emit(EntrepreneurError('Emprendedor no encontrado'));
      }
    } catch (e) {
      emit(EntrepreneurError(e.toString()));
    }
  }

  Future<void> _onAddEntrepreneur(
    AddEntrepreneur event,
    Emitter<EntrepreneurState> emit,
  ) async {
    emit(EntrepreneurLoading());
    try {
      final data = await _apiService.post(
        ApiConfig.getEntrepreneursUrl(),
        event.entrepreneurData,
        requiresAuth: true,
      );
      if (data != null) {
        final newEntrepreneur = Entrepreneur.fromJson(data);
        _entrepreneurCache[newEntrepreneur.id] = newEntrepreneur;
        emit(EntrepreneurSuccess('Emprendedor agregado exitosamente'));
        // Fetch updated list immediately
        final updatedData = await _apiService.get(ApiConfig.getEntrepreneursUrl());
        if (updatedData != null) {
          final entrepreneurs = (updatedData as List)
              .map((item) => Entrepreneur.fromJson(item))
              .toList();
          _updateCache(entrepreneurs);
          emit(EntrepreneurLoaded(entrepreneurs));
        }
      } else {
        emit(EntrepreneurError('Error al agregar emprendedor'));
      }
    } catch (e) {
      emit(EntrepreneurError(e.toString()));
    }
  }

  Future<void> _onUpdateEntrepreneur(
    UpdateEntrepreneur event,
    Emitter<EntrepreneurState> emit,
  ) async {
    emit(EntrepreneurLoading());
    try {
      final data = await _apiService.put(
        ApiConfig.getEntrepreneurByIdUrl(event.entrepreneurData['id']),
        event.entrepreneurData,
        requiresAuth: true,
      );
      if (data != null) {
        final updatedEntrepreneur = Entrepreneur.fromJson(data);
        _entrepreneurCache[updatedEntrepreneur.id] = updatedEntrepreneur;
        emit(EntrepreneurSuccess('Emprendedor actualizado exitosamente'));
        // Fetch updated list immediately
        final updatedData = await _apiService.get(ApiConfig.getEntrepreneursUrl());
        if (updatedData != null) {
          final entrepreneurs = (updatedData as List)
              .map((item) => Entrepreneur.fromJson(item))
              .toList();
          _updateCache(entrepreneurs);
          emit(EntrepreneurLoaded(entrepreneurs));
        }
      } else {
        emit(EntrepreneurError('Error al actualizar emprendedor'));
      }
    } catch (e) {
      emit(EntrepreneurError(e.toString()));
    }
  }

  Future<void> _onDeleteEntrepreneur(
    DeleteEntrepreneur event,
    Emitter<EntrepreneurState> emit,
  ) async {
    emit(EntrepreneurLoading());
    try {
      final success = await _apiService.delete(
        ApiConfig.getEntrepreneurByIdUrl(event.id),
        requiresAuth: true,
      );
      if (success) {
        _entrepreneurCache.remove(event.id);
        emit(EntrepreneurSuccess('Emprendedor eliminado exitosamente'));
        // Fetch updated list immediately
        final updatedData = await _apiService.get(ApiConfig.getEntrepreneursUrl());
        if (updatedData != null) {
          final entrepreneurs = (updatedData as List)
              .map((item) => Entrepreneur.fromJson(item))
              .toList();
          _updateCache(entrepreneurs);
          emit(EntrepreneurLoaded(entrepreneurs));
        }
      } else {
        emit(EntrepreneurError('Error al eliminar emprendedor'));
      }
    } catch (e) {
      emit(EntrepreneurError(e.toString()));
    }
  }

  void _onClearError(
    ClearEntrepreneurError event,
    Emitter<EntrepreneurState> emit,
  ) {
    emit(EntrepreneurInitial());
  }

  void _updateCache(List<Entrepreneur> entrepreneurs) {
    for (var entrepreneur in entrepreneurs) {
      _entrepreneurCache[entrepreneur.id] = entrepreneur;
    }
  }

  @override
  Future<void> close() {
    _entrepreneurCache.clear();
    return super.close();
  }
} 