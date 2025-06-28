import 'package:flutter/material.dart';
import '../../../services/dashboard_service.dart';

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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reservas = await _dashboardService.getReservas();
      setState(() {
        _reservas = reservas;
        _filteredReservas = reservas;
        _isLoading = false;
        _updateResumen();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          onPressed: () {},
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
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: Text('No se encontraron reservas.')),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredReservas.length,
      itemBuilder: (context, index) {
        final res = _filteredReservas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con código y estado
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                      child: const Icon(Icons.book_online, color: Color(0xFF9C27B0), size: 24),
                      radius: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reserva ${res['codigo_reserva'] ?? res['codigo'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Creada el ${_buildFechaText(res['created_at'] ?? res['fecha'])}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildEstadoChip(res['estado'] ?? ''),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Información del cliente
                _buildInfoSection(
                  'Cliente',
                  Icons.person,
                  [
                    res['usuario']?['name'] ?? res['cliente'] ?? 'Sin nombre',
                    res['usuario']?['email'] ?? res['email'] ?? 'Sin email',
                  ],
                ),
                const SizedBox(height: 12),
                
                // Servicios
                _buildServiciosSection(res),
                const SizedBox(height: 16),
                
                // Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 22),
                      tooltip: 'Editar',
                      onPressed: () {
                        // TODO: Implementar edición
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      tooltip: 'Eliminar',
                      onPressed: () {
                        // TODO: Implementar eliminación
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.sync_alt, color: Colors.orange, size: 22),
                      tooltip: 'Cambiar Estado',
                      onPressed: () {
                        // TODO: Implementar cambio de estado
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

  Widget _buildInfoSection(String title, IconData icon, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 4),
          child: Text(
            item,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildServiciosSection(Map<String, dynamic> res) {
    final servicios = res['servicios'] ?? res['reserva_servicios'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.miscellaneous_services, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Servicios (${servicios is List ? servicios.length : 0})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (servicios is List && servicios.isNotEmpty) ...[
          ...servicios.map<Widget>((s) => Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 6, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s['nombre'] ?? s['servicio']?['nombre'] ?? 'Servicio sin nombre',
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
        ] else ...[
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'No hay servicios asociados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _buildFechaText(dynamic fecha) {
    if (fecha == null) return 'Fecha no disponible';
    DateTime? dt;
    if (fecha is DateTime) {
      dt = fecha;
    } else if (fecha is String) {
      try {
        dt = DateTime.parse(fecha);
      } catch (_) {}
    }
    if (dt == null) return 'Fecha inválida';
    return '${dt.day.toString().padLeft(2, '0')} ${_mes(dt.month)}. ${dt.year}';
  }

  Widget _buildEstadoChip(String estado) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'pendiente':
        color = Colors.orange;
        break;
      case 'confirmada':
        color = Colors.green;
        break;
      case 'completada':
        color = Colors.blue;
        break;
      case 'cancelada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(estado[0].toUpperCase() + estado.substring(1)),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }

  String _mes(int mes) {
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return meses[mes];
  }
} 