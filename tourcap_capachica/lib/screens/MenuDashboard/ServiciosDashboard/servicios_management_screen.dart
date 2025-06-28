import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/servicios/servicios_bloc.dart';
import '../../../blocs/servicios/servicios_event.dart';
import '../../../blocs/servicios/servicios_state.dart';
import '../../../models/servicio.dart';
import '../../../services/servicio_service.dart';

class ServiciosManagementScreen extends StatefulWidget {
  const ServiciosManagementScreen({Key? key}) : super(key: key);

  @override
  State<ServiciosManagementScreen> createState() => _ServiciosManagementScreenState();
}

class _ServiciosManagementScreenState extends State<ServiciosManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedEmprendedor = 'Todos';
  String _selectedCategoria = 'Todos';
  String _selectedEstado = 'Todos';
  List<String> _emprendedores = ['Todos'];
  List<String> _categorias = ['Todos'];
  bool _isLoadingFilters = true;

  @override
  void initState() {
    super.initState();
    context.read<ServiciosBloc>().add(LoadServicios());
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() => _isLoadingFilters = true);
    try {
      final servicioService = ServicioService();
      final emprendedores = await servicioService.getEmprendedores();
      final categorias = await servicioService.getCategorias();
      setState(() {
        _emprendedores = ['Todos', ...emprendedores.map((e) => e['nombre']?.toString() ?? '').where((n) => n.isNotEmpty)];
        _categorias = ['Todos', ...categorias.map((c) => c['nombre']?.toString() ?? '').where((n) => n.isNotEmpty)];
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() => _isLoadingFilters = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar filtros: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyFilters() {
    context.read<ServiciosBloc>().add(FilterServicios(
      searchQuery: _searchController.text,
      emprendedor: _selectedEmprendedor,
      categoria: _selectedCategoria,
      estado: _selectedEstado,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Servicios'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: BlocBuilder<ServiciosBloc, ServiciosState>(
        builder: (context, state) {
          if (state is ServiciosLoading || _isLoadingFilters) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ServiciosError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is ServiciosLoaded) {
            return _buildContent(state.filteredServicios);
          }
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a formulario de nuevo servicio
        },
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Servicio',
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> servicios) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildServiciosTable(servicios),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9C27B0))),
            const SizedBox(height: 12),
            // Primera fila: búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o descripción',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).scaffoldBackgroundColor,
              ),
              onChanged: (_) => _applyFilters(),
            ),
            const SizedBox(height: 12),
            // Segunda fila: emprendedor, categoría, estado - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                
                if (isSmallScreen) {
                  // En pantallas pequeñas, apilar verticalmente
                  return Column(
                    children: [
                      _buildDropdownFilter(
                        value: _selectedEmprendedor,
                        items: _emprendedores,
                        label: 'Emprendedor',
                        onChanged: (v) {
                          setState(() => _selectedEmprendedor = v ?? 'Todos');
                          _applyFilters();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownFilter(
                              value: _selectedCategoria,
                              items: _categorias,
                              label: 'Categoría',
                              onChanged: (v) {
                                setState(() => _selectedCategoria = v ?? 'Todos');
                                _applyFilters();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdownFilter(
                              value: _selectedEstado,
                              items: const ['Todos', 'Activo', 'Inactivo'],
                              label: 'Estado',
                              onChanged: (v) {
                                setState(() => _selectedEstado = v ?? 'Todos');
                                _applyFilters();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // En pantallas grandes, usar Wrap
                  return Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 220,
                        child: _buildDropdownFilter(
                          value: _selectedEmprendedor,
                          items: _emprendedores,
                          label: 'Emprendedor',
                          onChanged: (v) {
                            setState(() => _selectedEmprendedor = v ?? 'Todos');
                            _applyFilters();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: _buildDropdownFilter(
                          value: _selectedCategoria,
                          items: _categorias,
                          label: 'Categoría',
                          onChanged: (v) {
                            setState(() => _selectedCategoria = v ?? 'Todos');
                            _applyFilters();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: _buildDropdownFilter(
                          value: _selectedEstado,
                          items: const ['Todos', 'Activo', 'Inactivo'],
                          label: 'Estado',
                          onChanged: (v) {
                            setState(() => _selectedEstado = v ?? 'Todos');
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Filtrar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildServiciosTable(List<Map<String, dynamic>> servicios) {
    if (servicios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text('No se encontraron servicios.')),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: servicios.length,
      itemBuilder: (context, index) {
        final servicio = Servicio.fromJson(servicios[index]);
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      child: Icon(Icons.miscellaneous_services_rounded, color: Theme.of(context).colorScheme.secondary, size: 28),
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            servicio.nombre, 
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            servicio.descripcion, 
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    _buildEstadoChip(servicio.estado),
                  ],
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 400;
                    
                    if (isSmallScreen) {
                      // En pantallas muy pequeñas, apilar verticalmente
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(Icons.attach_money, 'S/. ${servicio.precio.toStringAsFixed(2)}', Colors.green),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.person, servicio.emprendedor, const Color(0xFF7B1FA2)),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.category, servicio.categoriasText, Colors.orange),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.schedule, servicio.horariosText, Colors.blue),
                        ],
                      );
                    } else {
                      // En pantallas normales, usar Wrap
                      return Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoRow(Icons.attach_money, 'S/. ${servicio.precio.toStringAsFixed(2)}', Colors.green),
                          _buildInfoRow(Icons.person, servicio.emprendedor, const Color(0xFF7B1FA2)),
                          _buildInfoRow(Icons.category, servicio.categoriasText, Colors.orange),
                          _buildInfoRow(Icons.schedule, servicio.horariosText, Colors.blue),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                      tooltip: 'Editar',
                      onPressed: () {
                        // TODO: Navegar a formulario de edición
                      },
                    ),
                    IconButton(
                      icon: Icon(servicio.estado ? Icons.visibility_off : Icons.visibility, color: Colors.orange, size: 22),
                      tooltip: servicio.estado ? 'Desactivar' : 'Activar',
                      onPressed: () {
                        // TODO: Cambiar estado
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      tooltip: 'Eliminar',
                      onPressed: () {
                        // TODO: Eliminar servicio
                      },
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text, 
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoChip(bool estado) {
    return Chip(
      label: Text(estado ? 'Activo' : 'Inactivo'),
      backgroundColor: estado ? Colors.green[100] : Colors.red[100],
      labelStyle: TextStyle(color: estado ? Colors.green[800] : Colors.red[800]),
    );
  }
} 