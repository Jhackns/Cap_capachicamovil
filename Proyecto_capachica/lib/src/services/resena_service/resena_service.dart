// Placeholder for ResenaService
import '../../models/reserva/resena_model.dart';

class ResenaService {
  Future<Resena> submitResena({
    required String reservaId,
    required String alojamientoId,
    required String usuarioId,
    required double calificacion,
    String? comentario,
  }) async {
    print('ResenaService (Placeholder): Submitting resena...');
    await Future.delayed(const Duration(seconds: 1));
    return Resena(
      id: 'srv_resena_${DateTime.now().millisecondsSinceEpoch}',
      reservaId: reservaId,
      alojamientoId: alojamientoId,
      usuarioId: usuarioId,
      calificacion: calificacion,
      comentario: comentario,
      fechaResena: DateTime.now(),
      nombreUsuario: 'Usuario (Service)',
      fotoUsuarioUrl: 'https://via.placeholder.com/50?text=US',
    );
  }

  Future<List<Resena>> getResenasForAlojamiento(String alojamientoId) async {
    print('ResenaService (Placeholder): Fetching resenas for alojamiento $alojamientoId');
    await Future.delayed(const Duration(seconds: 1));
    return [
      Resena(id: 'srv_rev1', reservaId: 'res_abc', alojamientoId: alojamientoId, usuarioId: 'user_srv_1', calificacion: 4.5, comentario: 'Excelente vista desde el servicio.', fechaResena: DateTime.now().subtract(const Duration(days: 5)), nombreUsuario: 'Maria L.', fotoUsuarioUrl: 'https://via.placeholder.com/50?text=ML'),
      Resena(id: 'srv_rev2', reservaId: 'res_def', alojamientoId: alojamientoId, usuarioId: 'user_srv_2', calificacion: 3.5, comentario: 'Podría mejorar la conexión a internet.', fechaResena: DateTime.now().subtract(const Duration(days: 3)), nombreUsuario: 'Juan R.', fotoUsuarioUrl: 'https://via.placeholder.com/50?text=JR'),
    ];
  }

  Future<List<Resena>> getUserResenas(String usuarioId) async {
    print('ResenaService (Placeholder): Fetching resenas for user $usuarioId');
    await Future.delayed(const Duration(seconds: 1));
    return [
      Resena(id: 'srv_rev_user1', reservaId: 'res_user_abc', alojamientoId: 'alo1', usuarioId: usuarioId, calificacion: 5, comentario: 'Mi primera reseña!', fechaResena: DateTime.now().subtract(const Duration(days:15)), nombreUsuario: 'Yo Mismo', fotoUsuarioUrl: 'https://via.placeholder.com/50?text=YM'),
    ];
  }
}
