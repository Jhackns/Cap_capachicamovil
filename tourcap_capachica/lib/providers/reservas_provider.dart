import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/reservas/reservas_bloc.dart';
import '../services/reserva_service.dart';
import '../services/servicio_service.dart';
import '../services/dashboard_service.dart';
import '../services/user_service.dart';

class ReservasProvider extends StatelessWidget {
  final Widget child;

  const ReservasProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ReservaService>(
          create: (context) => ReservaService(),
        ),
        RepositoryProvider<ServicioService>(
          create: (context) => ServicioService(),
        ),
        RepositoryProvider<DashboardService>(
          create: (context) => DashboardService(),
        ),
        RepositoryProvider<UserService>(
          create: (context) => UserService(),
        ),
      ],
      child: BlocProvider<ReservasBloc>(
        create: (context) => ReservasBloc(
          reservaService: context.read<ReservaService>(),
          servicioService: context.read<ServicioService>(),
          dashboardService: context.read<DashboardService>(),
          userService: context.read<UserService>(),
        ),
        child: child,
      ),
    );
  }
} 