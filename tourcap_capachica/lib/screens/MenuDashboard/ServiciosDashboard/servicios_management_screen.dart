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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filtros de búsqueda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9C27B0))),
            const SizedBox(height: 12),
            // Primera fila: búsqueda y emprendedor
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o descripción',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _applyFilters(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedEmprendedor,
                    items: _emprendedores.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedEmprendedor = v ?? 'Todos');
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Emprendedor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Segunda fila: categoría y estado
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategoria,
                    items: _categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) {
                      setState(() => _selectedCategoria = v ?? 'Todos');
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _selectedEstado,
                    items: const [
                      DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'Inactivo', child: Text('Inactivo')),
                    ],
                    onChanged: (v) {
                      setState(() => _selectedEstado = v ?? 'Todos');
                      _applyFilters();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                      child: const Icon(Icons.miscellaneous_services_rounded, color: Color(0xFF9C27B0), size: 28),
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(servicio.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(servicio.descripcion, style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                        ],
                      ),
                    ),
                    _buildEstadoChip(servicio.estado),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green, size: 20),
                    const SizedBox(width: 4),
                    Text('S/. ${servicio.precio.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    const Icon(Icons.person, color: Color(0xFF7B1FA2), size: 20),
                    const SizedBox(width: 4),
                    Text(servicio.emprendedor, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, color: Colors.orange, size: 20),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(servicio.categoriasText, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                    Text(servicio.horariosText, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
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

  Widget _buildEstadoChip(bool estado) {
    return Chip(
      label: Text(estado ? 'Activo' : 'Inactivo'),
      backgroundColor: estado ? Colors.green[100] : Colors.red[100],
      labelStyle: TextStyle(color: estado ? Colors.green[800] : Colors.red[800]),
    );
  }
} 