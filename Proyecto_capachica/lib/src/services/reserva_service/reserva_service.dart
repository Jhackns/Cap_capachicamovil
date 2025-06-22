// Placeholder for ReservaService
import '../../models/reserva/reserva_model.dart';

class ReservaService {
  Future<Reserva> createReserva({
    required String alojamientoId,
    required String usuarioId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int numeroHuespedes,
    required double costoTotal,
    String? notasEspeciales,
  }) async {
    print('ReservaService (Placeholder): Creating reserva...');
    await Future.delayed(const Duration(seconds: 1));
    return Reserva(
      id: 'srv_res_${DateTime.now().millisecondsSinceEpoch}',
      alojamientoId: alojamientoId,
      usuarioId: usuarioId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      numeroHuespedes: numeroHuespedes,
      costoTotal: costoTotal,
      estado: EstadoReserva.confirmada, // Default to confirmed for mock
      fechaCreacion: DateTime.now(),
      notasEspeciales: notasEspeciales,
    );
  }

  Future<List<Reserva>> getUserReservas(String usuarioId) async {
    print('ReservaService (Placeholder): Fetching reservas for user $usuarioId');
    await Future.delayed(const Duration(seconds: 1));
     return [
      Reserva(id: 'srv_res1', alojamientoId: 'alo1', usuarioId: usuarioId, fechaInicio: DateTime.now().subtract(const Duration(days: 10)), fechaFin: DateTime.now().subtract(const Duration(days: 8)), numeroHuespedes: 2, costoTotal: 280.0, estado: EstadoReserva.completada, fechaCreacion: DateTime.now().subtract(const Duration(days: 15))),
      Reserva(id: 'srv_res2', alojamientoId: 'alo2', usuarioId: usuarioId, fechaInicio: DateTime.now().add(const Duration(days: 7)), fechaFin: DateTime.now().add(const Duration(days: 10)), numeroHuespedes: 1, costoTotal: 330.0, estado: EstadoReserva.confirmada, fechaCreacion: DateTime.now().subtract(const Duration(days: 2))),
    ];
  }

  Future<void> cancelReserva(String reservaId, String usuarioId) async {
    print('ReservaService (Placeholder): Canceling reserva $reservaId for user $usuarioId');
    await Future.delayed(const Duration(seconds: 1));
    // No return, assumes success or throws error
  }

  Future<List<Reserva>> getReservasForAlojamiento(String alojamientoId) async {
    print('ReservaService (Placeholder): Fetching reservas for alojamiento $alojamientoId');
    await Future.delayed(const Duration(seconds: 1));
    // Mock: return some reservas linked to this alojamientoId
    return [
       Reserva(id: 'srv_res_alo1', alojamientoId: alojamientoId, usuarioId: 'user_abc', fechaInicio: DateTime.now().subtract(const Duration(days: 2)), fechaFin: DateTime.now(), numeroHuespedes: 2, costoTotal: 250.0, estado: EstadoReserva.completada, fechaCreacion: DateTime.now().subtract(const Duration(days: 5))),
       Reserva(id: 'srv_res_alo2', alojamientoId: alojamientoId, usuarioId: 'user_xyz', fechaInicio: DateTime.now().add(const Duration(days: 3)), fechaFin: DateTime.now().add(const Duration(days: 6)), numeroHuespedes: 3, costoTotal: 450.0, estado: EstadoReserva.confirmada, fechaCreacion: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }
}
