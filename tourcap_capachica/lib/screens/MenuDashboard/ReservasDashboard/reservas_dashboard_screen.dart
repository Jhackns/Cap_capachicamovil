import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/reservas/reservas_bloc.dart';
import '../../../blocs/reservas/reservas_event.dart';
//import '../../../blocs/reservas/reservas_state.dart';
import '../../../services/dashboard_service.dart';
import 'reserva_form_screen.dart';

class ReservasDashboardScreen extends StatefulWidget {
  @override
  _ReservasDashboardScreenState createState() => _ReservasDashboardScreenState();
}

class _ReservasDashboardScreenState extends State<ReservasDashboardScreen> {
  // Filtros
  final TextEditingController _codigoController = TextEditingController();
  String _estado = 'Todos';
  DateTime? _fechaInicio;

  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _reservas = [];
  List<Map<String, dynamic>> _filteredReservas = [];
  bool _isLoading = true;
  String? _error;

  // Resumen de ejemplo (se actualizará luego con datos reales)
  Map<String, int> _resumen = {
    'Total': 0,
    'Pendientes': 0,
    'Confirmadas': 0,
    'Completadas': 0,
    'Canceladas': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchReservas();
    // Agregar listener para filtros en tiempo real
    _codigoController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filteredReservas = _reservas.where((reserva) {
        // Filtro por código
        final codigo = (reserva['codigo_reserva'] ?? reserva['codigo'] ?? '').toString().toLowerCase();
        final codigoFilter = _codigoController.text.toLowerCase();
        if (codigoFilter.isNotEmpty && !codigo.contains(codigoFilter)) {
          return false;
        }

        // Filtro por estado
        final estado = (reserva['estado'] ?? '').toString();
        if (_estado != 'Todos' && estado != _estado) {
          return false;
        }

        // Filtro por fecha
        if (_fechaInicio != null) {
          final fechaReserva = _parseFecha(reserva['created_at'] ?? reserva['fecha']);
          if (fechaReserva == null || fechaReserva.isBefore(_fechaInicio!)) {
            return false;
          }
        }

        return true;
      }).toList();
      _updateResumen();
    });
  }

  DateTime? _parseFecha(dynamic fecha) {
    if (fecha == null) return null;
    if (fecha is DateTime) return fecha;
    if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (_) {}
    }
    return null;
  }

  Future<void> _fetchReservas() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('=== FETCHING RESERVAS ===');
      final reservas = await _dashboardService.getReservas();
      print('Reservas obtenidas: ${reservas.length}');
      
      if (reservas.isNotEmpty) {
        print('=== ESTRUCTURA DE LA PRIMERA RESERVA ===');
        final primeraReserva = reservas.first;
        primeraReserva.forEach((key, value) {
          print('$key: $value (${value.runtimeType})');
        });
        
        // Verificar campos específicos
        print('Código: ${primeraReserva['codigo_reserva'] ?? primeraReserva['codigo']}');
        print('Cliente: ${primeraReserva['usuario'] ?? primeraReserva['cliente']}');
        print('Total: ${primeraReserva['total']}');
        print('Estado: ${primeraReserva['estado']}');
        print('Servicios: ${primeraReserva['servicios'] ?? primeraReserva['reserva_servicios']}');
      }
      
      if (mounted) {
        setState(() {
          _reservas = reservas;
          _filteredReservas = reservas;
          _isLoading = false;
          _updateResumen();
        });
      }
    } catch (e) {
      print('Error al obtener reservas: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateResumen() {
    final Map<String, int> resumen = {
      'Total': _filteredReservas.length,
      'Pendientes': 0,
      'Confirmadas': 0,
      'Completadas': 0,
      'Canceladas': 0,
    };
    for (final r in _filteredReservas) {
      final estado = (r['estado'] ?? '').toString().toLowerCase();
      if (estado == 'pendiente') resumen['Pendientes'] = resumen['Pendientes']! + 1;
      if (estado == 'confirmada') resumen['Confirmadas'] = resumen['Confirmadas']! + 1;
      if (estado == 'completada') resumen['Completadas'] = resumen['Completadas']! + 1;
      if (estado == 'cancelada') resumen['Canceladas'] = resumen['Canceladas']! + 1;
    }
    _resumen = resumen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetchReservas,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gestionar Reservas', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                        const SizedBox(height: 4),
                        Text('Panel general de administración de reservas', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 20),
                        _buildResumenBar(),
                        const SizedBox(height: 28),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 600;
                            if (isSmall) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gestión de Reservas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  _buildAccionButtons(),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('Gestión de Reservas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  _buildAccionButtons(),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 18),
                        _buildFiltros(context),
                        const SizedBox(height: 18),
                        _buildTablaReservas(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildResumenBar() {
    final estados = [
      {'label': 'Total', 'color': Colors.purple},
      {'label': 'Pendientes', 'color': Colors.orange},
      {'label': 'Confirmadas', 'color': Colors.green},
      {'label': 'Completadas', 'color': Colors.blue},
      {'label': 'Canceladas', 'color': Colors.red},
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: estados.map((e) {
            return Column(
              children: [
                Text('${_resumen[e['label']] ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: e['color'] as Color)),
                const SizedBox(height: 2),
                Text(e['label'].toString(), style: TextStyle(color: e['color'] as Color, fontSize: 13)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAccionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('En desarrollo'),
                content: Text('El calendario estará disponible próximamente.'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cerrar'))],
              ),
            );
          },
          icon: Icon(Icons.calendar_today, color: Color(0xFF9C27B0)),
          label: Text('Ver Calendario'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReservaFormScreen(),
              ),
            ).then((result) {
              if (result == true) {
                _fetchReservas();
              }
            });
          },
          icon: Icon(Icons.add),
          label: Text('Nueva Reserva'),
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9C27B0)),
        ),
      ],
    );
  }

  Widget _buildFiltros(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: 'Código de reserva',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: _estado,
                items: ['Todos', 'Pendiente', 'Confirmada', 'Cancelada', 'Completada']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _estado = v ?? 'Todos');
                  _applyFilters();
                },
                decoration: InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaInicio ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _fechaInicio = picked);
                    _applyFilters();
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Inicio',
                      hintText: 'dd/mm/aaaa',
                      prefixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    controller: TextEditingController(
                      text: _fechaInicio != null
                          ? '${_fechaInicio!.day.toString().padLeft(2, '0')}/${_fechaInicio!.month.toString().padLeft(2, '0')}/${_fechaInicio!.year}'
                          : '',
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _codigoController.clear();
                  _estado = 'Todos';
                  _fechaInicio = null;
                });
                _applyFilters();
              },
              icon: Icon(Icons.clear),
              label: Text('Limpiar Filtros'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaReservas(BuildContext context) {
    if (_filteredReservas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No se encontraron reservas', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    // Usar cards para móvil en lugar de tabla
    return Column(
      children: _filteredReservas.map((reserva) {
        // Extraer datos de la reserva
        final codigo = reserva['codigo_reserva'] ?? reserva['codigo'] ?? 'N/A';
        final cliente = reserva['usuario'] ?? reserva['cliente'];
        final clienteNombre = cliente is Map ? cliente['name'] : cliente?.toString() ?? 'N/A';
        final fechaCreacion = _formatFecha(reserva['created_at'] ?? reserva['fecha']);
        final estado = reserva['estado'] ?? 'pendiente';
        final total = reserva['total'] ?? 0.0;
        
        // Extraer servicios
        final servicios = reserva['servicios'] ?? reserva['reserva_servicios'] ?? [];
        final serviciosTexto = servicios.isNotEmpty 
            ? servicios.map((s) => s['servicio']?['nombre'] ?? s['nombre'] ?? 'Servicio').join(', ')
            : 'Sin servicios';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Primera fila: Código y Estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Código: $codigo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cliente: $clienteNombre',
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
                        color: _getStatusColor(estado).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(estado),
                        style: TextStyle(
                          color: _getStatusColor(estado),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Segunda fila: Fecha (sin total)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha: $fechaCreacion',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                // Tercera fila: Servicios
                Text(
                  'Servicios: $serviciosTexto',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Cuarta fila: Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewReserva(reserva),
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
                        onPressed: () => _editReserva(reserva),
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
                        onPressed: () => _deleteReserva(reserva['id']),
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
      }).toList(),
    );
  }

  void _editReserva(Map<String, dynamic> reserva) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservaFormScreen(reserva: reserva),
      ),
    ).then((_) {
      // Recargar la lista después de editar
      _fetchReservas();
    });
  }

  void _viewReserva(Map<String, dynamic> reserva) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reserva ${reserva['codigo_reserva'] ?? reserva['codigo']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cliente: ${reserva['cliente']?['name'] ?? 'N/A'}'),
              Text('Estado: ${_getStatusText(reserva['estado'])}'),
              Text('Total: S/ ${(reserva['total'] ?? 0).toStringAsFixed(2)}'),
              if (reserva['notas'] != null) Text('Notas: ${reserva['notas']}'),
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

  void _deleteReserva(int reservaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta reserva? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Eliminando reserva...'),
                  backgroundColor: Colors.blue,
                ),
              );
              
              try {
                // Llamar al BLoC para eliminar
                context.read<ReservasBloc>().add(DeleteReserva(reservaId));
                
                // Esperar un momento y recargar
                await Future.delayed(const Duration(milliseconds: 500));
                _fetchReservas();
                
                // Mostrar mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reserva eliminada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Mostrar mensaje de error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.green;
      case 'completada':
        return Colors.blue;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.pending;
      case 'confirmada':
        return Icons.done;
      case 'completada':
        return Icons.check_circle;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'completada':
        return 'Completada';
      case 'cancelada':
        return 'Cancelada';
      default:
        return 'Estado no reconocido';
    }
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return 'N/A';
    if (fecha is DateTime) {
      return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
    }
    if (fecha is String) {
      try {
        final parsedDate = DateTime.parse(fecha);
        return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
      } catch (_) {}
    }
    return 'N/A';
  }
} 