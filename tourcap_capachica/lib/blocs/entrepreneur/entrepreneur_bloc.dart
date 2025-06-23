import 'package:flutter_bloc/flutter_bloc.dart';
import 'entrepreneur_event.dart';
import 'entrepreneur_state.dart';
import '../../services/emprendedor_service.dart';
import '../../models/entrepreneur.dart';

class EntrepreneurBloc extends Bloc<EntrepreneurEvent, EntrepreneurState> {
  final EmprendedorService _service = EmprendedorService();

  EntrepreneurBloc() : super(EntrepreneurInitial()) {
    on<LoadEntrepreneurs>((event, emit) async {
      emit(EntrepreneurLoading());
      try {
        final list = await _service.fetchEntrepreneurs();
        final entrepreneurs = list.map((e) => Entrepreneur.fromJson(e as Map<String, dynamic>)).toList();
        emit(EntrepreneurLoaded(entrepreneurs));
      } catch (e) {
        emit(EntrepreneurError(e.toString()));
      }
    });
    on<SearchEntrepreneurs>((event, emit) async {
      emit(EntrepreneurLoading());
      try {
        final list = await _service.fetchEntrepreneurs(query: event.query);
        final entrepreneurs = list.map((e) => Entrepreneur.fromJson(e as Map<String, dynamic>)).toList();
        emit(EntrepreneurLoaded(entrepreneurs));
      } catch (e) {
        emit(EntrepreneurError(e.toString()));
      }
    });
    on<CreateEntrepreneur>((event, emit) async {
      emit(EntrepreneurLoading());
      try {
        await _service.createEntrepreneur(event.data);
        emit(EntrepreneurSuccess('Emprendedor creado exitosamente.'));
        final list = await _service.fetchEntrepreneurs();
        final entrepreneurs = list.map((e) => Entrepreneur.fromJson(e as Map<String, dynamic>)).toList();
        emit(EntrepreneurLoaded(entrepreneurs));
      } catch (e) {
        emit(EntrepreneurError(e.toString()));
      }
    });
    on<UpdateEntrepreneur>((event, emit) async {
      emit(EntrepreneurLoading());
      try {
        await _service.updateEntrepreneur(event.id, event.data);
        emit(EntrepreneurSuccess('Emprendedor actualizado exitosamente.'));
        final list = await _service.fetchEntrepreneurs();
        final entrepreneurs = list.map((e) => Entrepreneur.fromJson(e as Map<String, dynamic>)).toList();
        emit(EntrepreneurLoaded(entrepreneurs));
      } catch (e) {
        emit(EntrepreneurError(e.toString()));
      }
    });
    on<DeleteEntrepreneur>((event, emit) async {
      emit(EntrepreneurLoading());
      try {
        await _service.deleteEntrepreneur(event.id);
        emit(EntrepreneurSuccess('Emprendedor eliminado exitosamente.'));
        final list = await _service.fetchEntrepreneurs();
        final entrepreneurs = list.map((e) => Entrepreneur.fromJson(e as Map<String, dynamic>)).toList();
        emit(EntrepreneurLoaded(entrepreneurs));
      } catch (e) {
        emit(EntrepreneurError(e.toString()));
      }
    });
  }
} 