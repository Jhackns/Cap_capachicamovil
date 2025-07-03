import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/reservas_service.dart';
import '../../../models/reserva.dart';
import '../../../models/reserva_servicio.dart';
import 'pago_confirmacion_screen.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({Key? key}) : super(key: key);

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  final ReservasService _reservasService = ReservasService();
  
  List<Reserva> _reservas = [];
  List<Reserva> _reservasFiltradas = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  String _filtroEstado = 'todos';
  String _busqueda = '';
  
  // Estados de edición de notas
  Map<int, bool> _editandoNotas = {};
  Map<int, TextEditingController> _controladoresNotas = {};
  
  // Estadísticas
  Map<String, int> _estadisticas = {
    'total': 0,
    'pendientes': 0,
    'confirmadas': 0,
    'completadas': 0,
    'canceladas': 0,
  };

  // Estado para mostrar el formulario de cambio de horario por servicio
  Map<int, bool> _editandoHorarioServicio = {};
  Map<int, DateTime?> _nuevaFechaServicio = {};
  Map<int, TimeOfDay?> _nuevaHoraInicioServicio = {};
  Map<int, TimeOfDay?> _nuevaHoraFinServicio = {};

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  @override
  void dispose() {
    // Limpiar controladores
    _controladoresNotas.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reservas = await _reservasService.obtenerMisReservas();
      
      if (mounted) {
        setState(() {
          _reservas = reservas;
          _calcularEstadisticas();
          _aplicarFiltros();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _calcularEstadisticas() {
    _estadisticas = {
      'total': _reservas.length,
      'pendientes': _reservas.where((r) => r.estado == 'pendiente').length,
      'confirmadas': _reservas.where((r) => r.estado == 'confirmada').length,
      'completadas': _reservas.where((r) => r.estado == 'completada').length,
      'canceladas': _reservas.where((r) => r.estado == 'cancelada').length,
    };
  }

  void _aplicarFiltros() {
    _reservasFiltradas = _reservas.where((reserva) {
      // Filtro por estado
      if (_filtroEstado != 'todos' && reserva.estado != _filtroEstado) {
        return false;
      }
      
      // Filtro por búsqueda
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        final codigoReserva = reserva.codigo?.toLowerCase() ?? '';
        
        // Buscar en servicios
        bool encontradoEnServicios = false;
        if (reserva.servicios != null) {
          for (final servicio in reserva.servicios!) {
            final nombreServicio = servicio.nombreServicio?.toLowerCase() ?? '';
            if (nombreServicio.contains(busquedaLower)) {
              encontradoEnServicios = true;
              break;
            }
          }
        }
        
        if (!codigoReserva.contains(busquedaLower) && !encontradoEnServicios) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  void _iniciarEdicionNotas(int reservaId) {
    if (!_controladoresNotas.containsKey(reservaId)) {
      _controladoresNotas[reservaId] = TextEditingController(
        text: _reservas.firstWhere((r) => r.id == reservaId).notas ?? '',
      );
    }
    
    setState(() {
      _editandoNotas[reservaId] = true;
    });
  }

  void _cancelarEdicionNotas(int reservaId) {
    setState(() {
      _editandoNotas[reservaId] = false;
    });
  }

  Future<void> _guardarNotas(int reservaId) async {
    try {
      final notas = _controladoresNotas[reservaId]?.text ?? '';
      final success = await _reservasService.actualizarNotasReserva(reservaId, notas);
      
      if (success) {
        // Actualizar la reserva local
        final index = _reservas.indexWhere((r) => r.id == reservaId);
        if (index != -1) {
          setState(() {
            _reservas[index] = _reservas[index].copyWith(notas: notas);
            _editandoNotas[reservaId] = false;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notas guardadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar las notas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.blue;
      case 'completada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoText(String estado) {
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
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarReservas,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                  onRefresh: _cargarReservas,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Descripción
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mis Reservas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gestiona tus reservas de servicios turísticos',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Estadísticas
                        _buildEstadisticas(),
                        const SizedBox(height: 24),

                        // Filtros
                        _buildFiltros(),
                        const SizedBox(height: 24),

                        // Lista de reservas
                        _buildListaReservas(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error al cargar las reservas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Error desconocido',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _cargarReservas,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas de Reservas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildEstadisticaCard(
              'Total',
              '${_estadisticas['total']}',
              Icons.list_alt,
              Colors.blue,
            ),
            _buildEstadisticaCard(
              'Pendientes',
              '${_estadisticas['pendientes']}',
              Icons.pending,
              Colors.orange,
            ),
            _buildEstadisticaCard(
              'Confirmadas',
              '${_estadisticas['confirmadas']}',
              Icons.check_circle,
              Colors.green,
            ),
            _buildEstadisticaCard(
              'Completadas',
              '${_estadisticas['completadas']}',
              Icons.done_all,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadisticaCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtros',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _filtroEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: 'todos', child: Text('Todos los estados')),
                  const DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                  const DropdownMenuItem(value: 'confirmada', child: Text('Confirmadas')),
                  const DropdownMenuItem(value: 'completada', child: Text('Completadas')),
                  const DropdownMenuItem(value: 'cancelada', child: Text('Canceladas')),
                ],
                onChanged: (value) {
                  setState(() {
                    _filtroEstado = value ?? 'todos';
                    _aplicarFiltros();
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por código o servicio...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _busqueda = value;
                    _aplicarFiltros();
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListaReservas() {
    if (_reservasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No hay reservas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se encontraron reservas con los filtros aplicados',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Listado de Reservas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _reservasFiltradas.length,
          itemBuilder: (context, index) {
            return _buildReservaCard(_reservasFiltradas[index]);
          },
        ),
      ],
    );
  }

  Widget _buildReservaCard(Reserva reserva) {
    final editando = _editandoNotas[reserva.id] ?? false;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la Reserva
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reserva #${reserva.codigo ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Creada el ${DateFormat('dd/MM/yyyy').format(reserva.fechaCreacion)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(reserva.estado),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getEstadoText(reserva.estado),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notas de la Reserva
            _buildSeccionNotas(reserva, editando),
            const SizedBox(height: 16),

            // Servicios Incluidos
            _buildServiciosIncluidos(reserva),
            const SizedBox(height: 16),

            // Acciones generales
            _buildAccionesGenerales(reserva),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionNotas(Reserva reserva, bool editando) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notas de la Reserva',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (editando) ...[
          TextField(
            controller: _controladoresNotas[reserva.id],
            decoration: const InputDecoration(
              hintText: 'Agregar notas...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _guardarNotas(reserva.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _cancelarEdicionNotas(reserva.id),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reserva.notas?.isNotEmpty == true
                        ? reserva.notas!
                        : 'Sin notas',
                    style: TextStyle(
                      color: reserva.notas?.isNotEmpty == true
                          ? Colors.black87
                          : Colors.grey[600],
                      fontStyle: reserva.notas?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _iniciarEdicionNotas(reserva.id),
                  tooltip: 'Editar notas',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServiciosIncluidos(Reserva reserva) {
    final servicios = reserva.servicios ?? [];
    
    if (servicios.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Servicios Incluidos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No hay servicios en esta reserva',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servicios Incluidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...servicios.map((servicio) => _buildServicioCard(servicio)).toList(),
      ],
    );
  }

  Widget _buildServicioCard(ReservaServicio servicio) {
    final editandoHorario = _editandoHorarioServicio[servicio.id] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del servicio y emprendedor
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      servicio.nombreServicio ?? 'Servicio sin nombre',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      servicio.nombreEmprendedor ?? 'Emprendedor no especificado',
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
                  color: _getEstadoColor(servicio.estado),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getEstadoText(servicio.estado),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Detalles del servicio
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetalleServicio(
                      'Fecha',
                      DateFormat('dd/MM/yyyy').format(servicio.fechaInicio),
                      Icons.calendar_today,
                    ),
                    const SizedBox(height: 8),
                    _buildDetalleServicio(
                      'Horario',
                      '${servicio.horaInicio?.substring(0, 5)} - ${servicio.horaFin?.substring(0, 5)}',
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetalleServicio(
                      'Duración',
                      '${servicio.duracionMinutos} minutos',
                      Icons.timer,
                    ),
                    const SizedBox(height: 8),
                    if (servicio.notas?.isNotEmpty == true)
                      _buildDetalleServicio(
                        'Notas',
                        servicio.notas!,
                        Icons.note,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Formulario de cambio de horario
          if (editandoHorario) _buildFormularioCambioHorario(servicio),
          // Acciones del servicio
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _editandoHorarioServicio[servicio.id] = !(editandoHorario);
                      if (_editandoHorarioServicio[servicio.id] == true) {
                        _nuevaFechaServicio[servicio.id] = servicio.fechaInicio;
                        _nuevaHoraInicioServicio[servicio.id] = TimeOfDay(
                          hour: int.parse(servicio.horaInicio.split(':')[0]),
                          minute: int.parse(servicio.horaInicio.split(':')[1]),
                        );
                        _nuevaHoraFinServicio[servicio.id] = TimeOfDay(
                          hour: int.parse(servicio.horaFin.split(':')[0]),
                          minute: int.parse(servicio.horaFin.split(':')[1]),
                        );
                      }
                    });
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Cambiar horario'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Cancelar servicio
                    final ok = await _reservasService.cambiarEstadoServicio(servicio.id, 'cancelado');
                    if (ok) {
                      await _cargarReservas();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Servicio cancelado'), backgroundColor: Colors.red),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al cancelar servicio'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Cancelar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioCambioHorario(ReservaServicio servicio) {
    final selectedFecha = _nuevaFechaServicio[servicio.id] ?? servicio.fechaInicio;
    final selectedHoraInicio = _nuevaHoraInicioServicio[servicio.id] ?? TimeOfDay(hour: int.parse(servicio.horaInicio.split(':')[0]), minute: int.parse(servicio.horaInicio.split(':')[1]));
    final selectedHoraFin = _nuevaHoraFinServicio[servicio.id] ?? TimeOfDay(hour: int.parse(servicio.horaFin.split(':')[0]), minute: int.parse(servicio.horaFin.split(':')[1]));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedFecha,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _nuevaFechaServicio[servicio.id] = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Fecha'),
                  child: Text(DateFormat('dd/MM/yyyy').format(selectedFecha)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedHoraInicio,
                  );
                  if (picked != null) {
                    setState(() {
                      _nuevaHoraInicioServicio[servicio.id] = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Hora inicio'),
                  child: Text(selectedHoraInicio.format(context)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedHoraFin,
                  );
                  if (picked != null) {
                    setState(() {
                      _nuevaHoraFinServicio[servicio.id] = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Hora fin'),
                  child: Text(selectedHoraFin.format(context)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Aquí deberías llamar a un endpoint para actualizar el horario del servicio reservado
                // Simulación local:
                setState(() {
                  _editandoHorarioServicio[servicio.id] = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horario actualizado (simulado)'), backgroundColor: Colors.green),
                );
                // TODO: Llamar a un método real para actualizar el horario en el backend
              },
              child: const Text('Guardar'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _editandoHorarioServicio[servicio.id] = false;
                });
              },
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetalleServicio(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccionesGenerales(Reserva reserva) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones de la Reserva',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PagoConfirmacionScreen(
                        reserva: reserva,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.payment, size: 16),
                label: const Text('💳 Confirmar y pagar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Cancelar reserva
                  final ok = await _reservasService.cancelarReserva(reserva.id);
                  if (ok) {
                    await _cargarReservas();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reserva cancelada'), backgroundColor: Colors.red),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error al cancelar reserva'), backgroundColor: Colors.red),
                    );
                  }
                },
                icon: const Icon(Icons.cancel, size: 16),
                label: const Text('Cancelar reserva'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar ver detalle completo
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad en desarrollo'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Ver detalle completo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9C27B0),
            ),
          ),
        ),
      ],
    );
  }
} 