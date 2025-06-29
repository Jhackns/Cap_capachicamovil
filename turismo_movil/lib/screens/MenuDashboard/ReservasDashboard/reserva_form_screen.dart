import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/reservas/reservas_bloc.dart';
import '../../../blocs/reservas/reservas_event.dart';
import '../../../blocs/reservas/reservas_state.dart';
import '../../../models/reserva_servicio_form.dart';

class ReservaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? reserva;

  const ReservaFormScreen({Key? key, this.reserva}) : super(key: key);

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _notasController = TextEditingController();
  
  // Variables para el formulario
  Map<String, dynamic>? _selectedCliente;
  int? _clienteIdToSelect; // Para manejar la selección al editar
  String _estado = 'pendiente';
  List<ReservaServicioForm> _servicios = [];
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Listas de datos
  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _serviciosDisponibles = [];
  List<Map<String, dynamic>> _emprendedores = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadData();
  }

  void _initializeForm() {
    // Generar código automático
    _codigoController.text = _generateCodigoReserva();
    
    // Agregar al menos un servicio por defecto
    _servicios.add(ReservaServicioForm());
    
    if (widget.reserva != null) {
      _loadReservaData();
    }
  }

  String _generateCodigoReserva() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (1000 + (now.millisecondsSinceEpoch % 9000)).toString();
    return 'RES$year$month$day$random';
  }

  void _loadReservaData() {
    final reserva = widget.reserva!;
    _codigoController.text = reserva['codigo_reserva'] ?? _generateCodigoReserva();
    _estado = reserva['estado'] ?? 'pendiente';
    _notasController.text = reserva['notas'] ?? '';
    
    // Cargar cliente - no establecer _selectedCliente aquí, se hará después de cargar usuarios
    _clienteIdToSelect = reserva['usuario']?['id'] ?? reserva['usuario_id'];
    
    // Cargar servicios
    final serviciosData = reserva['servicios'] ?? reserva['reserva_servicios'] ?? [];
    _servicios.clear();
    for (final servicioData in serviciosData) {
      try {
        _servicios.add(ReservaServicioForm.fromJson(servicioData));
      } catch (e) {
        print('Error parsing servicio: $e');
        print('Servicio data: $servicioData');
        // Crear un servicio vacío en caso de error
        _servicios.add(ReservaServicioForm());
      }
    }
    
    if (_servicios.isEmpty) {
      _servicios.add(ReservaServicioForm());
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar usuarios, servicios y emprendedores
      context.read<ReservasBloc>().add(LoadEmprendedores());
      context.read<ReservasBloc>().add(LoadServicios());
      context.read<ReservasBloc>().add(LoadUsuarios());
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addServicio() {
    setState(() {
      _servicios.add(ReservaServicioForm());
    });
  }

  void _removeServicio(int index) {
    setState(() {
      _servicios.removeAt(index);
    });
  }

  void _updateServicio(int index, ReservaServicioForm servicio) {
    setState(() {
      _servicios[index] = servicio;
    });
  }

  double _calculateTotal() {
    return _servicios.fold(0.0, (total, servicio) => total + (servicio.precio * servicio.cantidad));
  }

  Future<void> _saveReserva() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente'), backgroundColor: Colors.red),
      );
      return;
    }
    
    if (_servicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añade al menos un servicio'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final reservaData = {
        'usuario_id': _selectedCliente!['id'],
        'codigo_reserva': _codigoController.text.trim(),
        'estado': _estado,
        'notas': _notasController.text.trim(),
        'servicios': _servicios.map((s) => s.toJson()).toList(),
      };

      if (widget.reserva != null) {
        context.read<ReservasBloc>().add(UpdateReserva(widget.reserva!['id'], reservaData));
      } else {
        context.read<ReservasBloc>().add(CreateReserva(reservaData));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reserva != null ? 'Editar Reserva' : 'Nueva Reserva'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ReservasBloc, ReservasState>(
        listener: (context, state) {
          if (state is ReservaCreated || state is ReservaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.reserva != null ? 'Reserva actualizada exitosamente' : 'Reserva creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is ReservasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          try {
            // Actualizar datos cuando se cargan
            if (state is ReservasLoaded) {
              _usuarios = state.usuarios ?? [];
              _serviciosDisponibles = state.servicios ?? [];
              _emprendedores = state.emprendedores ?? [];
              
              // Seleccionar cliente si estamos editando
              if (_clienteIdToSelect != null && _selectedCliente == null) {
                final cliente = _usuarios.firstWhere(
                  (user) => user['id'] == _clienteIdToSelect,
                  orElse: () => _usuarios.isNotEmpty ? _usuarios.first : {},
                );
                if (cliente.isNotEmpty) {
                  _selectedCliente = cliente;
                }
              }
            }

            return _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildBasicInfoSection(),
                          const SizedBox(height: 24),
                          _buildServiciosSection(),
                          const SizedBox(height: 24),
                          _buildTotalSection(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error en el formulario: $e'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Reservas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF9C27B0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete los datos básicos de la reserva',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cliente
            _buildClienteField(),
            const SizedBox(height: 16),
            
            // Código de Reserva
            _buildCodigoField(),
            const SizedBox(height: 16),
            
            // Estado
            _buildEstadoField(),
            const SizedBox(height: 16),
            
            // Notas Generales
            _buildNotasField(),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cliente *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedCliente?['id'],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
            hintText: 'Selecciona un cliente',
          ),
          isExpanded: true,
          items: _usuarios.map((usuario) {
            return DropdownMenuItem<int>(
              value: usuario['id'],
              child: Text(
                '${usuario['name']} (${usuario['email']})',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final selectedUser = _usuarios.firstWhere(
                (user) => user['id'] == value,
                orElse: () => {},
              );
              setState(() => _selectedCliente = selectedUser.isNotEmpty ? selectedUser : null);
            }
          },
          validator: (value) {
            if (value == null) return 'Selecciona un cliente';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCodigoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Código de Reserva *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El código es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _codigoController.text = _generateCodigoReserva();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Generar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEstadoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _estado,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info),
          ),
          items: [
            {'value': 'pendiente', 'label': 'Pendiente'},
            {'value': 'confirmada', 'label': 'Confirmada'},
            {'value': 'cancelada', 'label': 'Cancelada'},
            {'value': 'completada', 'label': 'Completada'},
          ].map((e) {
            return DropdownMenuItem<String>(
              value: e['value'],
              child: Text(e['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _estado = value!);
          },
        ),
      ],
    );
  }

  Widget _buildNotasField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas Generales', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notasController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            hintText: 'Ej: Primera visita a Capachica, muy emocionado por conocer la zona.',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildServiciosSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Servicios Reservados',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF9C27B0),
                    ),
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    onPressed: _addServicio,
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C27B0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Añada los servicios que se incluyen en esta reserva',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            
            if (_servicios.isEmpty)
              _buildEmptyServiciosMessage()
            else
              ..._servicios.asMap().entries.map((entry) {
                final index = entry.key;
                final servicio = entry.value;
                return _buildServicioCard(index, servicio);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyServiciosMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Añada al menos un servicio. Debe añadir al menos un servicio a la reserva para poder continuar.',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicioCard(int index, ReservaServicioForm servicio) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Servicio #${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_servicios.length > 1)
                  IconButton(
                    onPressed: () => _removeServicio(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar servicio',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildServicioFields(index, servicio),
          ],
        ),
      ),
    );
  }

  Widget _buildServicioFields(int index, ReservaServicioForm servicio) {
    return Column(
      children: [
        // Servicio
        _buildServicioDropdown(index, servicio),
        const SizedBox(height: 16),
        
        // Emprendedor (solo lectura)
        if (servicio.servicioId != null)
          _buildEmprendedorField(servicio),
        
        const SizedBox(height: 16),
        
        // Fechas
        Row(
          children: [
            Expanded(child: _buildFechaInicioField(index, servicio)),
            const SizedBox(width: 16),
            Expanded(child: _buildFechaFinField(index, servicio)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Estado del servicio
        _buildServicioEstadoField(index, servicio),
        
        const SizedBox(height: 16),
        
        // Horarios
        Row(
          children: [
            Expanded(child: _buildHoraInicioField(index, servicio)),
            const SizedBox(width: 16),
            Expanded(child: _buildHoraFinField(index, servicio)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Duración, Cantidad y Precio
        Row(
          children: [
            Expanded(child: _buildDuracionField(servicio)),
            const SizedBox(width: 16),
            Expanded(child: _buildCantidadField(index, servicio)),
            const SizedBox(width: 16),
            Expanded(child: _buildPrecioField(index, servicio)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Notas
        Row(
          children: [
            Expanded(child: _buildNotasClienteField(index, servicio)),
            const SizedBox(width: 16),
            Expanded(child: _buildNotasEmprendedorField(index, servicio)),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Estado de disponibilidad
        _buildDisponibilidadStatus(servicio),
      ],
    );
  }

  Widget _buildServicioDropdown(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servicio *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: servicio.servicioId,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.miscellaneous_services),
            hintText: 'Selecciona un servicio',
          ),
          items: _serviciosDisponibles.map((s) {
            return DropdownMenuItem<int>(
              value: s['id'] as int,
              child: Text(s['nombre'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            final selectedServicio = _serviciosDisponibles.firstWhere(
              (s) => s['id'] == value,
              orElse: () => {},
            );
            
            final updatedServicio = servicio.copyWith(
              servicioId: value,
              emprendedorId: selectedServicio['emprendedor_id'],
              precio: (selectedServicio['precio'] ?? 0.0).toDouble(),
            );
            _updateServicio(index, updatedServicio);
            
            // Forzar la actualización del widget para recalcular el total
            setState(() {});
          },
          validator: (value) {
            if (value == null) return 'Selecciona un servicio';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmprendedorField(ReservaServicioForm servicio) {
    final emprendedor = _emprendedores.firstWhere(
      (e) => e['id'] == servicio.emprendedorId,
      orElse: () => {'nombre': 'No disponible'},
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Emprendedor', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: emprendedor['nombre'],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildFechaInicioField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha de inicio *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: servicio.fechaInicio ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              final updatedServicio = servicio.copyWith(fechaInicio: picked);
              _updateServicio(index, updatedServicio);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'dd/mm/aaaa',
              ),
              controller: TextEditingController(
                text: servicio.fechaInicio != null
                    ? '${servicio.fechaInicio!.day.toString().padLeft(2, '0')}/${servicio.fechaInicio!.month.toString().padLeft(2, '0')}/${servicio.fechaInicio!.year}'
                    : '',
              ),
              validator: (value) {
                if (servicio.fechaInicio == null) return 'Selecciona una fecha';
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFechaFinField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fecha de fin (opcional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: servicio.fechaFin ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              final updatedServicio = servicio.copyWith(fechaFin: picked);
              _updateServicio(index, updatedServicio);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'dd/mm/aaaa',
              ),
              controller: TextEditingController(
                text: servicio.fechaFin != null
                    ? '${servicio.fechaFin!.day.toString().padLeft(2, '0')}/${servicio.fechaFin!.month.toString().padLeft(2, '0')}/${servicio.fechaFin!.year}'
                    : '',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicioEstadoField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: servicio.estado,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.info),
          ),
          items: [
            {'value': 'pendiente', 'label': 'Pendiente'},
            {'value': 'confirmado', 'label': 'Confirmado'},
            {'value': 'cancelado', 'label': 'Cancelado'},
            {'value': 'completado', 'label': 'Completado'},
          ].map((e) {
            return DropdownMenuItem<String>(
              value: e['value'],
              child: Text(e['label']!),
            );
          }).toList(),
          onChanged: (value) {
            final updatedServicio = servicio.copyWith(estado: value!);
            _updateServicio(index, updatedServicio);
          },
        ),
      ],
    );
  }

  Widget _buildHoraInicioField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hora de inicio *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: servicio.horaInicio ?? const TimeOfDay(hour: 9, minute: 0),
            );
            if (picked != null) {
              final updatedServicio = servicio.copyWith(horaInicio: picked);
              _updateServicio(index, updatedServicio);
              _updateDuracion(index, updatedServicio);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                hintText: 'HH:MM',
              ),
              controller: TextEditingController(
                text: servicio.horaInicio != null
                    ? '${servicio.horaInicio!.hour.toString().padLeft(2, '0')}:${servicio.horaInicio!.minute.toString().padLeft(2, '0')}'
                    : '',
              ),
              validator: (value) {
                if (servicio.horaInicio == null) return 'Selecciona una hora';
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoraFinField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hora de fin *', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: servicio.horaFin ?? const TimeOfDay(hour: 10, minute: 0),
            );
            if (picked != null) {
              final updatedServicio = servicio.copyWith(horaFin: picked);
              _updateServicio(index, updatedServicio);
              _updateDuracion(index, updatedServicio);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                hintText: 'HH:MM',
              ),
              controller: TextEditingController(
                text: servicio.horaFin != null
                    ? '${servicio.horaFin!.hour.toString().padLeft(2, '0')}:${servicio.horaFin!.minute.toString().padLeft(2, '0')}'
                    : '',
              ),
              validator: (value) {
                if (servicio.horaFin == null) return 'Selecciona una hora';
                if (servicio.horaInicio != null && servicio.horaFin != null) {
                  final inicio = servicio.horaInicio!;
                  final fin = servicio.horaFin!;
                  if (fin.hour < inicio.hour || (fin.hour == inicio.hour && fin.minute <= inicio.minute)) {
                    return 'La hora de fin debe ser posterior a la hora de inicio';
                  }
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  void _updateDuracion(int index, ReservaServicioForm servicio) {
    servicio.calcularDuracion();
    _updateServicio(index, servicio);
  }

  Widget _buildDuracionField(ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Duración (minutos)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: servicio.duracionMinutos.toString(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
          ),
          readOnly: true,
        ),
      ],
    );
  }

  Widget _buildCantidadField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (servicio.cantidad > 1) {
                  final updatedServicio = servicio.copyWith(cantidad: servicio.cantidad - 1);
                  _updateServicio(index, updatedServicio);
                }
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                initialValue: servicio.cantidad.toString(),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
            IconButton(
              onPressed: () {
                final updatedServicio = servicio.copyWith(cantidad: servicio.cantidad + 1);
                _updateServicio(index, updatedServicio);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrecioField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Precio (S/)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: servicio.precio.toString(),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final precio = double.tryParse(value) ?? 0.0;
            final updatedServicio = servicio.copyWith(precio: precio);
            _updateServicio(index, updatedServicio);
          },
        ),
      ],
    );
  }

  Widget _buildNotasClienteField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas del cliente', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: servicio.notasCliente,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            hintText: 'Ej: Preferimos una habitación con vista al lago',
          ),
          maxLines: 2,
          onChanged: (value) {
            final updatedServicio = servicio.copyWith(notasCliente: value);
            _updateServicio(index, updatedServicio);
          },
        ),
      ],
    );
  }

  Widget _buildNotasEmprendedorField(int index, ReservaServicioForm servicio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notas del emprendedor', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: servicio.notasEmprendedor,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
            hintText: 'Ej: Servicio disponible en la fecha y horario seleccionados',
          ),
          maxLines: 2,
          onChanged: (value) {
            final updatedServicio = servicio.copyWith(notasEmprendedor: value);
            _updateServicio(index, updatedServicio);
          },
        ),
      ],
    );
  }

  Widget _buildDisponibilidadStatus(ReservaServicioForm servicio) {
    // TODO: Implementar verificación de disponibilidad real
    final isDisponible = true; // Placeholder
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisponible ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(color: isDisponible ? Colors.green.shade200 : Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isDisponible ? Icons.check_circle : Icons.error,
            color: isDisponible ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isDisponible 
                  ? 'Servicio disponible en la fecha y horario seleccionados'
                  : 'El servicio no está disponible en la fecha y horario seleccionados',
              style: TextStyle(
                color: isDisponible ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total estimado:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'S/ ${_calculateTotal().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.reserva != null ? 'Actualizar Reserva' : 'Crear Reserva'),
          ),
        ),
      ],
    );
  }

  void _onEmprendedorChanged(int index, int? emprendedorId) {
    if (emprendedorId != null) {
      final emprendedor = _emprendedores.firstWhere(
        (e) => e['id'] == emprendedorId,
        orElse: () => {'id': 0, 'nombre': 'No encontrado'},
      );
      
      final updatedServicio = _servicios[index].copyWith(
        emprendedorId: emprendedorId,
        emprendedorNombre: emprendedor['nombre'] ?? 'No encontrado',
      );
      
      _updateServicio(index, updatedServicio);
      
      // Recalcular el total
      setState(() {
        // El total se recalculará automáticamente en _calculateTotal()
      });
    }
  }
} 