import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/reserva/resena_model.dart';
import '../../services/resena_service/resena_service.dart'; // Placeholder

part 'resena_event.dart';
part 'resena_state.dart';

class ResenaBloc extends Bloc<ResenaEvent, ResenaState> {
  final ResenaService _resenaService;

  ResenaBloc(this._resenaService) : super(ResenaInitial()) {
    on<SubmitResena>(_onSubmitResena);
    on<LoadResenasForAlojamiento>(_onLoadResenasForAlojamiento);
    on<LoadUserResenas>(_onLoadUserResenas);
  }

  Future<void> _onSubmitResena(SubmitResena event, Emitter<ResenaState> emit) async {
    emit(ResenaSubmissionInProgress());
    try {
      // final nuevaResena = await _resenaService.submitResena(
      //   reservaId: event.reservaId,
      //   alojamientoId: event.alojamientoId,
      //   usuarioId: event.usuarioId,
      //   calificacion: event.calificacion,
      //   comentario: event.comentario,
      // );
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      final nuevaResena = Resena(
        id: 'resena_${DateTime.now().millisecondsSinceEpoch}',
        reservaId: event.reservaId,
        alojamientoId: event.alojamientoId,
        usuarioId: event.usuarioId,
        calificacion: event.calificacion,
        comentario: event.comentario,
        fechaResena: DateTime.now(),
        nombreUsuario: 'Usuario Mock', // Should come from user data
        fotoUsuarioUrl: 'https://via.placeholder.com/50'
      );
      emit(ResenaSubmissionSuccess(resena: nuevaResena));
      // Optionally, reload reviews for the alojamiento
      add(LoadResenasForAlojamiento(alojamientoId: event.alojamientoId));
    } catch (e) {
      emit(ResenaSubmissionFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadResenasForAlojamiento(LoadResenasForAlojamiento event, Emitter<ResenaState> emit) async {
    emit(ResenaLoading());
    try {
      // final resenas = await _resenaService.getResenasForAlojamiento(event.alojamientoId);
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      final mockResenas = _getMockResenas(event.alojamientoId);
      emit(ResenasLoaded(resenas: mockResenas));
    } catch (e) {
      emit(ResenasError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserResenas(LoadUserResenas event, Emitter<ResenaState> emit) async {
    emit(ResenaLoading());
    try {
      // final resenas = await _resenaService.getUserResenas(event.usuarioId);
      await Future.delayed(const Duration(seconds: 1));
      final mockResenas = _getMockResenas('anyAlojamientoId').where((r) => r.usuarioId == event.usuarioId).toList(); // Simple mock
      emit(ResenasLoaded(resenas: mockResenas));
    } catch (e) {
      emit(ResenasError(message: e.toString()));
    }
  }

  List<Resena> _getMockResenas(String alojamientoId) {
    return [
      Resena(id: 'rev1_${alojamientoId}', reservaId: 'res1', alojamientoId: alojamientoId, usuarioId: 'user123', calificacion: 5, comentario: '¡Increíble lugar! Muy recomendado.', fechaResena: DateTime.now().subtract(const Duration(days: 2)), nombreUsuario: 'Ana P.', fotoUsuarioUrl: 'https://via.placeholder.com/50?text=AP'),
      Resena(id: 'rev2_${alojamientoId}', reservaId: 'res_xyz', alojamientoId: alojamientoId, usuarioId: 'user456', calificacion: 4, comentario: 'Muy buena atención y limpieza. Volvería.', fechaResena: DateTime.now().subtract(const Duration(days: 1)), nombreUsuario: 'Carlos S.', fotoUsuarioUrl: 'https://via.placeholder.com/50?text=CS'),
    ];
  }
}
