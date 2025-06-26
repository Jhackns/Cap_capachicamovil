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
                                  Text('Gestión de Reservas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 40,
          ),
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateProperty.all(Color(0xFF9C27B0).withOpacity(0.08)),
            columns: const [
              DataColumn(label: Text('Código')),
              DataColumn(label: Text('Cliente')),
              DataColumn(label: Text('Fecha Creación')),
              DataColumn(label: Text('Servicios')),
              DataColumn(label: Text('Estado')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: _filteredReservas.map((res) {
              return DataRow(cells: [
                DataCell(Text(res['codigo_reserva'] ?? res['codigo'] ?? '')),
                DataCell(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(res['usuario']?['name'] ?? res['cliente'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(res['usuario']?['email'] ?? res['email'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                )),
                DataCell(_buildFechaCell(res['created_at'] ?? res['fecha'])),
                DataCell(_buildServiciosCell(res)),
                DataCell(_buildEstadoChip(res['estado'] ?? '')),
                DataCell(_buildAccionesCell(res)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAccionesCell(Map<String, dynamic> res) {
    return Wrap(
      spacing: 4,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue, size: 20),
          tooltip: 'Editar',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.delete, color: Colors.red, size: 20),
          tooltip: 'Eliminar',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.sync_alt, color: Colors.orange, size: 20),
          tooltip: 'Cambiar Estado',
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildFechaCell(dynamic fecha) {
    if (fecha == null) return Text('-');
    DateTime? dt;
    if (fecha is DateTime) {
      dt = fecha;
    } else if (fecha is String) {
      try {
        dt = DateTime.parse(fecha);
      } catch (_) {}
    }
    if (dt == null) return Text(fecha.toString());
    return Text('${dt.day.toString().padLeft(2, '0')} ${_mes(dt.month)}. ${dt.year}');
  }

  Widget _buildServiciosCell(Map<String, dynamic> res) {
    final servicios = res['servicios'] ?? res['reserva_servicios'] ?? [];
    if (servicios is List && servicios.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${servicios.length} servicios', style: TextStyle(fontWeight: FontWeight.bold)),
          ...servicios.map<Widget>((s) => Text(s['nombre'] ?? s['servicio']?['nombre'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[700]))).toList(),
        ],
      );
    }
    return Text('0 servicios');
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