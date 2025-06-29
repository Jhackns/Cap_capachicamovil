import 'package:flutter/material.dart';
import '../../../models/servicio.dart';
import '../../../services/servicio_service.dart';
import 'servicio_form_screen.dart';

class ServiciosManagementScreen extends StatefulWidget {
  const ServiciosManagementScreen({Key? key}) : super(key: key);

  @override
  State<ServiciosManagementScreen> createState() => _ServiciosManagementScreenState();
}

class _ServiciosManagementScreenState extends State<ServiciosManagementScreen> {
  final ServicioService _servicioService = ServicioService();
  List<Servicio> _servicios = [];
  bool _isLoading = true;
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServicios();
  }

  Future<void> _loadServicios() async {
    setState(() => _isLoading = true);
    try {
      print('🔄 Iniciando carga de servicios...');
      final serviciosData = await _servicioService.getServicios();
      print('📊 Datos recibidos: ${serviciosData.length} servicios');
      
      setState(() {
        _servicios = serviciosData.map((data) {
          print('🔧 Procesando servicio: ${data['nombre']}');
          return Servicio.fromJson(data);
        }).toList();
        _isLoading = false;
      });
      
      print('✅ Servicios cargados exitosamente: ${_servicios.length}');
    } catch (e) {
      print('❌ Error al cargar servicios: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar servicios: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteServicio(Servicio servicio) async {
    final confirmed = await _showConfirmationDialog(
      'Eliminar Servicio',
      '¿Estás seguro de que quieres eliminar el servicio "${servicio.nombre}"? Esta acción no se puede deshacer.',
    );

    if (confirmed) {
      try {
        await _servicioService.deleteServicio(servicio.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Servicio eliminado exitosamente'), backgroundColor: Colors.green),
        );
        _loadServicios();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar servicio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleEstadoServicio(Servicio servicio) async {
    try {
      await _servicioService.toggleEstadoServicio(servicio.id, !servicio.estado);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Servicio ${servicio.estado ? 'desactivado' : 'activado'} exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadServicios();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cambiar estado: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _navigateToForm([Servicio? servicio]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicioFormScreen(servicio: servicio),
      ),
    );

    if (result == true) {
      _loadServicios();
    }
  }

  List<Servicio> get _filteredServicios {
    if (_searchQuery.isEmpty) return _servicios;
    return _servicios.where((servicio) =>
        servicio.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        servicio.descripcion.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        servicio.emprendedor.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Servicios'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServicios.isEmpty
                    ? _buildEmptyState()
                    : _isGridView
                        ? _buildGridView()
                        : _buildListView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar servicios...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.miscellaneous_services_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay servicios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primer servicio para comenzar',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredServicios.length,
      itemBuilder: (context, index) {
        final servicio = _filteredServicios[index];
        return _buildServiceCard(servicio);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredServicios.length,
      itemBuilder: (context, index) {
        final servicio = _filteredServicios[index];
        return _buildServiceGridCard(servicio);
      },
    );
  }

  Widget _buildServiceCard(Servicio servicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        servicio.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servicio.emprendedor,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(servicio.estado),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              servicio.descripcion,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  'S/. ${servicio.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Text(
                  'Cap: ${servicio.capacidad}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    servicio.categoriasText,
                    style: TextStyle(
                      color: Colors.orange.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (servicio.ubicacionReferencia != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      servicio.ubicacionText,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.purple.shade600),
                const SizedBox(width: 4),
                Text(
                  servicio.horariosText,
                  style: TextStyle(
                    color: Colors.purple.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _navigateToForm(servicio),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9C27B0),
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleEstadoServicio(servicio),
                    icon: Icon(
                      servicio.estado ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(servicio.estado ? 'Desactivar' : 'Activar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: servicio.estado ? Colors.orange : Colors.green,
                      side: BorderSide(color: servicio.estado ? Colors.orange : Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteServicio(servicio),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGridCard(Servicio servicio) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    servicio.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(servicio.estado),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              servicio.emprendedor,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              servicio.descripcion,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.attach_money, size: 14, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  'S/. ${servicio.precio.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.people, size: 14, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Text(
                  '${servicio.capacidad}',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _navigateToForm(servicio),
                    child: const Icon(Icons.edit, size: 16),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9C27B0),
                      side: const BorderSide(color: Color(0xFF9C27B0)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteServicio(servicio),
                    child: const Icon(Icons.delete, size: 16),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: estado ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        estado ? 'Activo' : 'Inactivo',
        style: TextStyle(
          color: estado ? Colors.green.shade700 : Colors.red.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 