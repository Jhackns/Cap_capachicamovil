import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/planes/planes_bloc.dart';
import '../../../blocs/planes/planes_event.dart';
import '../../../blocs/planes/planes_state.dart';
import 'plan_form_screen.dart';
import '../../../services/dashboard_service.dart';

class PlanesManagementScreen extends StatefulWidget {
  const PlanesManagementScreen({Key? key}) : super(key: key);

  @override
  State<PlanesManagementScreen> createState() => _PlanesManagementScreenState();
}

class _PlanesManagementScreenState extends State<PlanesManagementScreen> {
  // Filtros
  final TextEditingController _searchController = TextEditingController();
  String _selectedEstado = 'Todos';
  String _selectedDificultad = 'Todas';
  String _selectedPublico = 'Todos';
  final _dashboardService = DashboardService();

  final List<String> _estadoOptions = ['Todos', 'Activos', 'Inactivos'];
  final List<String> _dificultadOptions = ['Todas', 'Fácil', 'Moderado', 'Difícil'];
  final List<String> _publicoOptions = ['Todos', 'Públicos', 'Privados'];

  @override
  void initState() {
    super.initState();
    context.read<PlanesBloc>().add(LoadPlanes());
    // Agregar listener para filtros en tiempo real
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    print('🔍 Aplicando filtros:');
    print('  - Búsqueda: "${_searchController.text}"');
    print('  - Estado: $_selectedEstado');
    print('  - Dificultad: $_selectedDificultad');
    print('  - Público: $_selectedPublico');
    
    context.read<PlanesBloc>().add(FilterPlanes(
      searchQuery: _searchController.text,
      estado: _selectedEstado,
      dificultad: _selectedDificultad,
      publico: _selectedPublico,
    ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedEstado = 'Todos';
      _selectedDificultad = 'Todas';
      _selectedPublico = 'Todos';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'planes_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlanFormScreen(),
            ),
          ).then((result) {
            if (result == true) {
              context.read<PlanesBloc>().add(LoadPlanes());
            }
          });
        },
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Gestión de Planes de Turismo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Administra y gestiona todos los planes turísticos del sistema',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Filtros
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtros',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Búsqueda
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        hintText: 'Nombre del plan...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filtros en fila
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Estado
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            value: _selectedEstado,
                            items: _estadoOptions
                                .map((estado) => DropdownMenuItem(
                                      value: estado,
                                      child: Text(estado),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedEstado = value ?? 'Todos');
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                          ),
                        ),

                        // Dificultad
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            value: _selectedDificultad,
                            items: _dificultadOptions
                                .map((dificultad) => DropdownMenuItem(
                                      value: dificultad,
                                      child: Text(dificultad),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedDificultad = value ?? 'Todas');
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              labelText: 'Dificultad',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                          ),
                        ),

                        // Público
                        SizedBox(
                          width: 150,
                          child: DropdownButtonFormField<String>(
                            value: _selectedPublico,
                            items: _publicoOptions
                                .map((publico) => DropdownMenuItem(
                                      value: publico,
                                      child: Text(publico),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedPublico = value ?? 'Todos');
                              _applyFilters();
                            },
                            decoration: InputDecoration(
                              labelText: 'Público',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              isDense: true,
                            ),
                          ),
                        ),

                        // Botón limpiar
                        ElevatedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpiar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Lista de planes
            Expanded(
              child: BlocConsumer<PlanesBloc, PlanesState>(
                listener: (context, state) {
                  // Solo mostrar mensajes para operaciones que no manejamos manualmente
                  if (state is PlanCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan creado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  // No mostrar errores aquí para evitar conflictos con SnackBars manuales
                },
                builder: (context, state) {
                  print('🔄 Estado actual del BLoC: ${state.runtimeType}');
                  
                  if (state is PlanesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PlanesError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<PlanesBloc>().add(LoadPlanes()),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is PlanesLoaded) {
                    print('📊 Planes cargados: ${state.planes.length}');
                    print('📊 Planes filtrados: ${state.filteredPlanes.length}');
                    
                    if (state.filteredPlanes.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No se encontraron planes', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        print('🔄 Refreshing planes...');
                        context.read<PlanesBloc>().add(LoadPlanes());
                      },
                      child: ListView.builder(
                        itemCount: state.filteredPlanes.length,
                        itemBuilder: (context, index) {
                          final plan = state.filteredPlanes[index];
                          return _buildPlanCard(plan);
                        },
                      ),
                    );
                  }

                  return const Center(child: Text('No hay datos'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final nombre = plan['nombre'] ?? 'Sin nombre';
    final descripcion = plan['descripcion'] ?? '';
    final duracion = plan['duracion_dias'] ?? 1;
    final precioRaw = plan['precio_total'] ?? 0.0;
    final precio = precioRaw is String ? double.tryParse(precioRaw) ?? 0.0 : (precioRaw is num ? precioRaw.toDouble() : 0.0);
    final capacidad = plan['capacidad'] ?? 0;
    final estado = plan['estado'] ?? 'activo';
    final dificultad = plan['dificultad'] ?? 'moderado';
    final esPublico = plan['es_publico'] ?? false;
    
    // Obtener emprendedores
    final emprendedores = plan['emprendedores'] ?? [];
    final organizadorPrincipal = emprendedores.isNotEmpty ? emprendedores.first : null;
    final totalEmprendedores = emprendedores.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y estado
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          descripcion,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(estado).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEstadoText(estado),
                    style: TextStyle(
                      color: _getEstadoColor(estado),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Información del plan
            Row(
              children: [
                // Dificultad
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDificultadColor(dificultad).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getDificultadText(dificultad),
                    style: TextStyle(
                      color: _getDificultadColor(dificultad),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Público/Privado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (esPublico ? Colors.green : Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    esPublico ? 'Público' : 'Privado',
                    style: TextStyle(
                      color: esPublico ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Emprendedores
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Organizador Principal',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    organizadorPrincipal?['nombre'] ?? 'No asignado',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (totalEmprendedores > 1)
                  Text(
                    '+${totalEmprendedores - 1} más',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Detalles del plan
            Row(
              children: [
                // Duración
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$duracion día${duracion > 1 ? 's' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // Precio
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'S/ ${precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Capacidad
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '$capacidad cupos',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewPlan(plan),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editPlan(plan),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _togglePlanEstado(plan),
                    icon: Icon(
                      estado == 'activo' ? Icons.block : Icons.check_circle,
                      size: 16,
                    ),
                    label: Text(estado == 'activo' ? 'Desactivar' : 'Activar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: estado == 'activo' ? Colors.orange : Colors.green,
                      side: BorderSide(
                        color: estado == 'activo' ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deletePlan(plan['id']),
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

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'inactivo':
        return Colors.red;
      case 'borrador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoText(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return 'Activo';
      case 'inactivo':
        return 'Inactivo';
      case 'borrador':
        return 'Borrador';
      default:
        return 'Desconocido';
    }
  }

  Color _getDificultadColor(String dificultad) {
    switch (dificultad.toLowerCase()) {
      case 'fácil':
      case 'facil':
        return Colors.green;
      case 'moderado':
        return Colors.orange;
      case 'difícil':
      case 'dificil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDificultadText(String dificultad) {
    switch (dificultad.toLowerCase()) {
      case 'fácil':
      case 'facil':
        return 'Fácil';
      case 'moderado':
        return 'Moderado';
      case 'difícil':
      case 'dificil':
        return 'Difícil';
      default:
        return 'Moderado';
    }
  }

  void _viewPlan(Map<String, dynamic> plan) {
    final precioRaw = plan['precio_total'] ?? 0.0;
    final precio = precioRaw is String ? double.tryParse(precioRaw) ?? 0.0 : (precioRaw is num ? precioRaw.toDouble() : 0.0);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(plan['nombre'] ?? 'Plan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descripción: ${plan['descripcion'] ?? 'Sin descripción'}'),
              const SizedBox(height: 8),
              Text('Duración: ${plan['duracion_dias'] ?? 1} día(s)'),
              const SizedBox(height: 8),
              Text('Precio: S/ ${precio.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Capacidad: ${plan['capacidad'] ?? 0} cupos'),
              const SizedBox(height: 8),
              Text('Estado: ${_getEstadoText(plan['estado'] ?? 'activo')}'),
              const SizedBox(height: 8),
              Text('Dificultad: ${_getDificultadText(plan['dificultad'] ?? 'moderado')}'),
              const SizedBox(height: 8),
              Text('Público: ${plan['es_publico'] == true ? 'Sí' : 'No'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editPlan(Map<String, dynamic> plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanFormScreen(plan: plan),
      ),
    ).then((result) {
      if (result == true) {
        context.read<PlanesBloc>().add(LoadPlanes());
      }
    });
  }

  void _togglePlanEstado(Map<String, dynamic> plan) async {
    final currentEstado = plan['estado'] ?? 'activo';
    // Si el estado actual es 'borrador', convertirlo a 'activo'
    final normalizedEstado = currentEstado == 'borrador' ? 'activo' : currentEstado;
    final newEstado = normalizedEstado == 'activo' ? 'inactivo' : 'activo';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newEstado == 'activo' ? 'Activar' : 'Desactivar'} plan'),
        content: Text('¿Estás seguro de que quieres ${newEstado == 'activo' ? 'activar' : 'desactivar'} este plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar indicador de carga
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text('${newEstado == 'activo' ? 'Activando' : 'Desactivando'} plan...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              
              try {
                print('🔄 Cambiando estado del plan ${plan['id']} de $currentEstado a $newEstado');
                await _dashboardService.updatePlan(plan['id'], {'estado': newEstado});
                
                // Resetear filtros y recargar datos
                if (mounted) {
                  print('🔄 Reseteando filtros y recargando planes...');
                  setState(() {
                    _searchController.clear();
                    _selectedEstado = 'Todos';
                    _selectedDificultad = 'Todas';
                    _selectedPublico = 'Todos';
                  });
                  
                  // Recargar la lista
                  context.read<PlanesBloc>().add(LoadPlanes());
                  
                  // Mostrar mensaje de éxito después de un pequeño delay
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Plan ${newEstado == 'activo' ? 'activado' : 'desactivado'} exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('❌ Error al cambiar estado del plan: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newEstado == 'activo' ? Colors.green : Colors.orange,
            ),
            child: Text(newEstado == 'activo' ? 'Activar' : 'Desactivar'),
          ),
        ],
      ),
    );
  }

  void _deletePlan(int planId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar plan'),
        content: const Text('¿Estás seguro de que quieres eliminar este plan? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar indicador de carga
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        const Text('Eliminando plan...'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              
              try {
                print('🗑️ Eliminando plan $planId...');
                await _dashboardService.deletePlan(planId);
                
                // Resetear filtros y recargar datos
                if (mounted) {
                  print('🔄 Reseteando filtros y recargando planes...');
                  setState(() {
                    _searchController.clear();
                    _selectedEstado = 'Todos';
                    _selectedDificultad = 'Todas';
                    _selectedPublico = 'Todos';
                  });
                  
                  // Recargar la lista
                  context.read<PlanesBloc>().add(LoadPlanes());
                  
                  // Mostrar mensaje de éxito después de un pequeño delay
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Plan eliminado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('❌ Error al eliminar plan: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 