import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/reserva_bloc/reserva_bloc.dart';
// import '../../models/reserva/reserva_model.dart';
// import '../alojamientos/alojamiento_detail_screen.dart'; // To view alojamiento
// import '../../widgets/reservas/submit_resena_widget.dart'; // To submit review

class UserReservasScreen extends StatefulWidget {
  const UserReservasScreen({super.key});

  @override
  State<UserReservasScreen> createState() => _UserReservasScreenState();
}

class _UserReservasScreenState extends State<UserReservasScreen> {
  @override
  void initState() {
    super.initState();
    // In a real app, get current user ID and load their reservas
    // final userId = context.read<AuthBloc>().state.user?.id; // Example
    // if (userId != null) {
    //   BlocProvider.of<ReservaBloc>(context).add(LoadUserReservas(usuarioId: userId));
    // }
    print('UserReservasScreen: InitState - Placeholder for loading user bookings.');
  }

  void _showSubmitResenaDialog(BuildContext context, String reservaId, String alojamientoId) {
    // showDialog(
    //   context: context,
    //   builder: (_) => SubmitResenaWidget(reservaId: reservaId, alojamientoId: alojamientoId),
    // );
    print('Show Submit Resena Dialog for Reserva ID: $reservaId, Alojamiento ID: $alojamientoId');
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Placeholder for Submit Reseña Dialog.')),
    );
  }

  void _cancelReservaDialog(BuildContext context, String reservaId, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: const Text('¿Estás seguro de que quieres cancelar esta reserva?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
          TextButton(
            onPressed: () {
              // BlocProvider.of<ReservaBloc>(context).add(CancelReserva(reservaId: reservaId, usuarioId: userId));
              print('Cancel Reserva: ID $reservaId');
              Navigator.of(ctx).pop();
            },
            child: const Text('Sí, Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Mock data for user's reservas
    final mockUserReservas = [
      {'id': 'res1', 'alojamientoNombre': 'Cabaña del Sol', 'alojamientoId': 'alo1', 'fechaInicio': '2024-03-10', 'fechaFin': '2024-03-12', 'estado': 'completada', 'costoTotal': 300.0},
      {'id': 'res2', 'alojamientoNombre': 'Casa Rural Pacha Mama', 'alojamientoId': 'alo2', 'fechaInicio': '2024-04-05', 'fechaFin': '2024-04-08', 'estado': 'confirmada', 'costoTotal': 360.0},
      {'id': 'res3', 'alojamientoNombre': 'Hospedaje Vista Hermosa', 'alojamientoId': 'alo3', 'fechaInicio': '2024-02-01', 'fechaFin': '2024-02-03', 'estado': 'canceladaPorUsuario', 'costoTotal': 200.0},
    ];
    // String currentUserId = 'mock_user_id'; // For cancel action

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      // body: BlocBuilder<ReservaBloc, ReservaState>(
      //   builder: (context, state) {
      //     if (state is UserReservasLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     } else if (state is UserReservasLoaded) {
      //       if (state.reservas.isEmpty) {
      //         return const Center(child: Text('No tienes ninguna reserva aún.'));
      //       }
      //       return ListView.builder(
      //         itemCount: state.reservas.length,
      //         itemBuilder: (context, index) {
      //           final reserva = state.reservas[index];
      //           // You'd need to fetch Alojamiento details or have them denormalized
      //           final alojamientoNombre = 'Alojamiento ID: ${reserva.alojamientoId}';
      //           return Card(
      //             margin: const EdgeInsets.all(8.0),
      //             child: ListTile(
      //               title: Text('Reserva en $alojamientoNombre'),
      //               subtitle: Text('Fechas: ${reserva.fechaInicio.toLocal().toString().split(' ')[0]} - ${reserva.fechaFin.toLocal().toString().split(' ')[0]}\nEstado: ${reserva.estado.name}'),
      //               trailing: reserva.estado == EstadoReserva.completada
      //                   ? TextButton(onPressed: () => _showSubmitResenaDialog(context, reserva.id, reserva.alojamientoId), child: Text('Dejar Reseña'))
      //                   : (reserva.estado == EstadoReserva.confirmada
      //                       ? TextButton(onPressed: () => _cancelReservaDialog(context, reserva.id, reserva.usuarioId), child: Text('Cancelar', style: TextStyle(color: Colors.red)))
      //                       : null),
      //               onTap: () { /* Navigate to AlojamientoDetailScreen(alojamientoId: reserva.alojamientoId) */ },
      //             ),
      //           );
      //         },
      //       );
      //     } else if (state is ReservasError) {
      //       return Center(child: Text('Error al cargar reservas: ${state.message}'));
      //     }
      //     return const Center(child: Text('Cargando tus reservas...'));
      //   },
      // ),
      body: ListView.builder(
        itemCount: mockUserReservas.length,
        itemBuilder: (context, index) {
          final reserva = mockUserReservas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reserva['alojamientoNombre'] as String, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Fechas: ${reserva['fechaInicio']} - ${reserva['fechaFin']}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Estado: ${reserva['estado']}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: reserva['estado'] == 'confirmada' ? Colors.green : (reserva['estado'] == 'completada' ? Colors.blue : Colors.grey) )),
                  Text('Costo Total: \$${(reserva['costoTotal'] as double).toStringAsFixed(2)} PEN', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (reserva['estado'] == 'completada')
                        TextButton(onPressed: () => _showSubmitResenaDialog(context, reserva['id'] as String, reserva['alojamientoId'] as String), child: const Text('Dejar Reseña')),
                      if (reserva['estado'] == 'confirmada')
                        TextButton(onPressed: () => _cancelReservaDialog(context, reserva['id'] as String, 'mock_user_id'), child: const Text('Cancelar Reserva', style: TextStyle(color: Colors.redAccent))),
                      TextButton(onPressed: () {
                        print('View Alojamiento: ${reserva['alojamientoId']}');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Placeholder: Ver detalles del alojamiento')));
                      }, child: const Text('Ver Alojamiento')),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      )
    );
  }
}
