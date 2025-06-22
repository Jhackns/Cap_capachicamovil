import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/reserva/reserva_model.dart';
import '../../services/reserva_service/reserva_service.dart'; // Placeholder

part 'reserva_event.dart';
part 'reserva_state.dart';

class ReservaBloc extends Bloc<ReservaEvent, ReservaState> {
  final ReservaService _reservaService;

  ReservaBloc(this._reservaService) : super(ReservaInitial()) {
    on<CreateReserva>(_onCreateReserva);
    on<LoadUserReservas>(_onLoadUserReservas);
    on<CancelReserva>(_onCancelReserva);
    on<LoadReservasForAlojamiento>(_onLoadReservasForAlojamiento);
  }

  Future<void> _onCreateReserva(CreateReserva event, Emitter<ReservaState> emit) async {
    emit(ReservaCreationInProgress());
    try {
      // final nuevaReserva = await _reservaService.createReserva(
      //   alojamientoId: event.alojamientoId,
      //   usuarioId: event.usuarioId,
      //   fechaInicio: event.fechaInicio,
      //   fechaFin: event.fechaFin,
      //   numeroHuespedes: event.numeroHuespedes,
      //   costoTotal: event.costoTotal,
      //   notasEspeciales: event.notasEspeciales,
      // );
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      final nuevaReserva = Reserva(
        id: 'res_${DateTime.now().millisecondsSinceEpoch}',
        alojamientoId: event.alojamientoId,
        usuarioId: event.usuarioId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        numeroHuespedes: event.numeroHuespedes,
        costoTotal: event.costoTotal,
        estado: EstadoReserva.confirmada, // Mock as confirmed
        fechaCreacion: DateTime.now(),
        notasEspeciales: event.notasEspeciales
      );
      emit(ReservaCreationSuccess(reserva: nuevaReserva));
    } catch (e) {
      emit(ReservaCreationFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadUserReservas(LoadUserReservas event, Emitter<ReservaState> emit) async {
    emit(UserReservasLoading());
    try {
      // final reservas = await _reservaService.getUserReservas(event.usuarioId);
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      final mockReservas = _getMockUserReservas(event.usuarioId);
      emit(UserReservasLoaded(reservas: mockReservas));
    } catch (e) {
      emit(ReservasError(message: e.toString()));
    }
  }

  Future<void> _onCancelReserva(CancelReserva event, Emitter<ReservaState> emit) async {
    emit(const ReservaLoading(message: 'Cancelando reserva...'));
    try {
      // await _reservaService.cancelReserva(event.reservaId, event.usuarioId);
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      emit(const ReservaOperationSuccess(message: 'Reserva cancelada exitosamente.'));
      // Reload user's reservas
      add(LoadUserReservas(usuarioId: event.usuarioId));
    } catch (e) {
      emit(ReservaOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadReservasForAlojamiento(LoadReservasForAlojamiento event, Emitter<ReservaState> emit) async {
    emit(const ReservaLoading(message: 'Cargando reservas del alojamiento...'));
    try {
      // final reservas = await _reservaService.getReservasForAlojamiento(event.alojamientoId);
      await Future.delayed(const Duration(seconds: 1)); // Simulate
      final mockReservas = _getMockUserReservas('anyUserId').where((r) => r.alojamientoId == event.alojamientoId).toList(); // Simple mock
      emit(UserReservasLoaded(reservas: mockReservas)); // Reusing state, could be a specific one
    } catch (e) {
      emit(ReservasError(message: e.toString()));
    }
  }

  List<Reserva> _getMockUserReservas(String usuarioId) {
    return [
      Reserva(id: 'res1', alojamientoId: 'alo1', usuarioId: usuarioId, fechaInicio: DateTime.now().subtract(const Duration(days: 5)), fechaFin: DateTime.now().subtract(const Duration(days: 3)), numeroHuespedes: 2, costoTotal: 300.0, estado: EstadoReserva.completada, fechaCreacion: DateTime.now().subtract(const Duration(days: 10))),
      Reserva(id: 'res2', alojamientoId: 'alo2', usuarioId: usuarioId, fechaInicio: DateTime.now().add(const Duration(days: 2)), fechaFin: DateTime.now().add(const Duration(days: 5)), numeroHuespedes: 1, costoTotal: 360.0, estado: EstadoReserva.confirmada, fechaCreacion: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }
}
