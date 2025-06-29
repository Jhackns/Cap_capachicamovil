import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../blocs/municipalidad/municipalidad_bloc.dart';
import '../../models/municipalidad.dart';
import './municipalidad_form_screen.dart';
import '../../services/dashboard_service.dart';
import '../../widgets/confirmation_dialog.dart';

class MunicipalidadManagementScreen extends StatelessWidget {
  const MunicipalidadManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dashboardService = Provider.of<DashboardService>(context, listen: false);
        return MunicipalidadBloc(dashboardService: dashboardService)
          ..add(FetchMunicipalidades());
      },
      child: const _MunicipalidadManagementView(),
    );
  }
}

class _MunicipalidadManagementView extends StatelessWidget {
  const _MunicipalidadManagementView({Key? key}) : super(key: key);

  void _navigateAndReload(BuildContext context, Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<MunicipalidadBloc>(context),
          child: screen,
        ),
      ),
    );
    if (result == true) {
      context.read<MunicipalidadBloc>().add(FetchMunicipalidades());
    }
  }

  void _deleteMunicipalidad(BuildContext context, int id) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Confirmar Eliminación',
      message: '¿Estás seguro de que quieres eliminar esta municipalidad?',
      confirmText: 'Eliminar',
      cancelText: 'Cancelar',
    );
    if (confirmed) {
      context.read<MunicipalidadBloc>().add(DeleteMunicipalidad(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<MunicipalidadBloc, MunicipalidadState>(
        listener: (context, state) {
          if (state is MunicipalidadOperationSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
          } else if (state is MunicipalidadError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is MunicipalidadLoading && state is! MunicipalidadLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MunicipalidadLoaded) {
            if (state.municipalidades.isEmpty) {
              return const Center(child: Text('No hay municipalidades.'));
            }
            final municipalidades = state.municipalidades;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: municipalidades.length,
              itemBuilder: (context, index) {
                final muni = municipalidades[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muni.nombre,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6A1B9A),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          muni.descripcion ?? 'Sin descripción',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateAndReload(
                                context,
                                MunicipalidadFormScreen(municipalidad: muni),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deleteMunicipalidad(context, muni.id),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Cargando municipalidades...'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _navigateAndReload(context, const MunicipalidadFormScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Municipalidad'),
        backgroundColor: const Color(0xFF9C27B0),
        heroTag: 'municipalidades_fab',
      ),
    );
  }
} 