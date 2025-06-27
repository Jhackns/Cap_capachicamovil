import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/asociaciones/asociaciones_bloc.dart';
import '../../../blocs/asociaciones/asociaciones_event.dart';
import '../../../blocs/asociaciones/asociaciones_state.dart';
import '../../../models/asociacion.dart';
import 'asociacion_form_screen.dart';

class AsociacionesManagementScreen extends StatefulWidget {
  const AsociacionesManagementScreen({Key? key}) : super(key: key);

  @override
  State<AsociacionesManagementScreen> createState() => _AsociacionesManagementScreenState();
}

class _AsociacionesManagementScreenState extends State<AsociacionesManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Todas';
  String _selectedMunicipalidad = 'Todas';

  @override
  void initState() {
    super.initState();
    context.read<AsociacionesBloc>().add(LoadAsociaciones());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<AsociacionesBloc>().add(FilterAsociaciones(
      searchQuery: _searchController.text,
      status: _selectedStatus,
      municipalidad: _selectedMunicipalidad,
    ));
  }

  void _showDeleteConfirmation(Asociacion asociacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar la asociación "${asociacion.nombre}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AsociacionesBloc>().add(DeleteAsociacion(asociacion.id));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AsociacionesBloc, AsociacionesState>(
        listener: (context, state) {
          if (state is AsociacionOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AsociacionOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AsociacionesBloc, AsociacionesState>(
          builder: (context, state) {
            if (state is AsociacionesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AsociacionesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar asociaciones',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AsociacionesBloc>().add(LoadAsociaciones());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is AsociacionesLoaded) {
              return _buildContent(state.filteredAsociaciones);
            }

            return const Center(child: Text('No hay datos disponibles'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AsociacionFormScreen(),
            ),
          );
          if (result == true) {
            context.read<AsociacionesBloc>().add(LoadAsociaciones());
          }
        },
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        heroTag: 'asociaciones_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> asociaciones) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.group_work_rounded,
                        size: 28,
                        color: Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gestión de Asociaciones',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Administra y gestiona las organizaciones de tu organización',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botón Nueva Asociación
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AsociacionFormScreen(),
                  ),
                );
                if (result == true) {
                  context.read<AsociacionesBloc>().add(LoadAsociaciones());
                }
              },
              icon: const Icon(Icons.add),
              label: const Text(
                'Nueva Asociación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Filtros
          _buildFilters(),
          const SizedBox(height: 16),

          // Lista de asociaciones
          if (asociaciones.isEmpty)
            _buildEmptyState()
          else
            _buildAsociacionesList(asociaciones),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar asociaciones...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                    DropdownMenuItem(value: 'Activas', child: Text('Activas')),
                    DropdownMenuItem(value: 'Inactivas', child: Text('Inactivas')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMunicipalidad,
                  decoration: InputDecoration(
                    labelText: 'Municipalidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Todas', child: Text('Todas')),
                    // Aquí se podrían agregar las municipalidades dinámicamente
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMunicipalidad = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.group_work_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No hay asociaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera asociación para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsociacionesList(List<Map<String, dynamic>> asociaciones) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: asociaciones.length,
      itemBuilder: (context, index) {
        final asociacionData = asociaciones[index];
        final asociacion = Asociacion.fromJson(asociacionData);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asociacion.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            asociacion.descripcionCorta,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: asociacion.estado ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        asociacion.estadoText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      asociacion.nombreMunicipalidad,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (asociacion.telefono != null || asociacion.email != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (asociacion.telefono != null) ...[
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          asociacion.telefono!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      if (asociacion.telefono != null && asociacion.email != null)
                        const SizedBox(width: 16),
                      if (asociacion.email != null) ...[
                        Icon(Icons.email, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          asociacion.email!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AsociacionFormScreen(asociacion: asociacion),
                          ),
                        );
                        if (result == true) {
                          context.read<AsociacionesBloc>().add(LoadAsociaciones());
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar',
                    ),
                    IconButton(
                      onPressed: () => _showDeleteConfirmation(asociacion),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 