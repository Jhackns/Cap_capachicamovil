import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/planes/planes_bloc.dart';
import '../../../blocs/planes/planes_event.dart';
import '../../../blocs/planes/planes_state.dart';
import '../../../services/dashboard_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PlanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? plan;

  const PlanFormScreen({Key? key, this.plan}) : super(key: key);

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dashboardService = DashboardService();
  
  // Controllers
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _queIncluyeController = TextEditingController();
  final _requerimientosController = TextEditingController();
  final _queLlevarController = TextEditingController();
  
  // Controllers para emprendedores participantes
  final List<TextEditingController> _porcentajeControllers = [];
  final List<TextEditingController> _descripcionControllers = [];
  
  // Variables del formulario
  String _estado = 'activo';
  String _dificultad = 'moderado';
  bool _esPublico = false;
  int _duracionDias = 1;
  int _capacidad = 1;
  double _precioTotal = 0.0;
  
  // Emprendedores
  List<Map<String, dynamic>> _emprendedores = [];
  List<Map<String, dynamic>> _emprendedoresParticipantes = [];
  Map<String, dynamic>? _selectedEmprendedorPrincipal;
  
  // Imágenes
  File? _imagenPrincipal;
  List<File> _imagenesGaleria = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _estadoOptions = ['activo', 'inactivo'];
  final List<String> _dificultadOptions = ['facil', 'moderado', 'dificil'];
  final List<String> _rolOptions = ['organizador', 'colaborador'];
  
  final Map<String, String> _estadoLabels = {
    'activo': 'Activo',
    'inactivo': 'Inactivo',
  };
  final Map<String, String> _dificultadLabels = {
    'facil': 'Fácil',
    'moderado': 'Moderado',
    'dificil': 'Difícil',
  };

  bool get isEditing => widget.plan != null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadData();
  }

  void _initializeForm() {
    if (isEditing) {
      final plan = widget.plan!;
      _nombreController.text = plan['nombre'] ?? '';
      _descripcionController.text = plan['descripcion'] ?? '';
      _queIncluyeController.text = plan['que_incluye'] ?? '';
      _requerimientosController.text = plan['requerimientos'] ?? '';
      _queLlevarController.text = plan['que_llevar'] ?? '';
      _estado = plan['estado'] ?? 'activo';
      
      // Normalizar la dificultad para que coincida con las opciones
      final dificultadBackend = plan['dificultad'] ?? 'moderado';
      if (dificultadBackend == 'facil' || dificultadBackend == 'fácil') {
        _dificultad = 'facil';
      } else if (dificultadBackend == 'dificil' || dificultadBackend == 'difícil') {
        _dificultad = 'dificil';
      } else {
        _dificultad = 'moderado';
      }
      
      _esPublico = plan['es_publico'] ?? false;
      _duracionDias = plan['duracion_dias'] ?? 1;
      _capacidad = plan['capacidad'] ?? 1;
      
      // Convertir precio a double si es string
      final precioRaw = plan['precio_total'] ?? 0.0;
      _precioTotal = precioRaw is String ? double.tryParse(precioRaw) ?? 0.0 : (precioRaw is num ? precioRaw.toDouble() : 0.0);
      
      // Cargar emprendedores participantes si existen
      if (plan['emprendedores'] != null) {
        _emprendedoresParticipantes = List<Map<String, dynamic>>.from(plan['emprendedores']);
        
        // Asegurar que los tipos de datos sean correctos
        for (int i = 0; i < _emprendedoresParticipantes.length; i++) {
          final emp = _emprendedoresParticipantes[i];
          // Convertir porcentaje_ganancia a double si es string
          if (emp['porcentaje_ganancia'] is String) {
            emp['porcentaje_ganancia'] = double.tryParse(emp['porcentaje_ganancia']) ?? 0.0;
          }
          // Asegurar que emprendedor_id sea int
          if (emp['emprendedor_id'] is String) {
            emp['emprendedor_id'] = int.tryParse(emp['emprendedor_id']);
          }
          // Asegurar que es_organizador_principal sea bool
          if (emp['es_organizador_principal'] is String) {
            emp['es_organizador_principal'] = emp['es_organizador_principal'] == 'true';
          }
          
          // Inicializar controllers para este emprendedor
          _porcentajeControllers.add(TextEditingController(
            text: (emp['porcentaje_ganancia'] ?? 0.0).toString(),
          ));
          _descripcionControllers.add(TextEditingController(
            text: emp['descripcion_participacion'] ?? '',
          ));
        }
      }
      
      // Inicializar emprendedor principal (legacy)
      if (plan['emprendedor_id'] != null) {
        // Se cargará cuando se obtengan los emprendedores en _loadData
        _selectedEmprendedorPrincipal = {'id': plan['emprendedor_id']};
        
        // Verificar si el emprendedor principal ya está en la lista de participantes
        final emprendedorPrincipalExiste = _emprendedoresParticipantes.any(
          (emp) => emp['emprendedor_id'] == plan['emprendedor_id']
        );
        
        // Si no existe en la lista de participantes, agregarlo
        if (!emprendedorPrincipalExiste) {
          _emprendedoresParticipantes.add({
            'emprendedor_id': plan['emprendedor_id'],
            'emprendedor_nombre': '', // Se llenará cuando se carguen los emprendedores
            'rol': 'organizador',
            'porcentaje_ganancia': 100.0,
            'descripcion_participacion': 'Organizador principal del plan',
            'es_organizador_principal': true,
          });
        }
      }
    }
  }

  void _loadData() async {
    try {
      final emprendedores = await _dashboardService.getEmprendedores();
      setState(() {
        _emprendedores = emprendedores;
        
        // Si estamos editando y hay un emprendedor seleccionado, actualizar la referencia completa
        if (isEditing && _selectedEmprendedorPrincipal != null && _selectedEmprendedorPrincipal!['id'] != null) {
          final emprendedorCompleto = emprendedores.firstWhere(
            (e) => e['id'] == _selectedEmprendedorPrincipal!['id'],
            orElse: () => {},
          );
          if (emprendedorCompleto.isNotEmpty) {
            _selectedEmprendedorPrincipal = emprendedorCompleto;
          }
        }
        
        // Actualizar los nombres de los emprendedores en la lista de participantes
        for (int i = 0; i < _emprendedoresParticipantes.length; i++) {
          final emprendedorId = _emprendedoresParticipantes[i]['emprendedor_id'];
          if (emprendedorId != null) {
            final emprendedor = emprendedores.firstWhere(
              (e) => e['id'] == emprendedorId,
              orElse: () => {},
            );
            if (emprendedor.isNotEmpty) {
              _emprendedoresParticipantes[i]['emprendedor_nombre'] = emprendedor['nombre'] ?? '';
            }
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar emprendedores: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _queIncluyeController.dispose();
    _requerimientosController.dispose();
    _queLlevarController.dispose();
    
    // Limpiar controllers de emprendedores
    for (final controller in _porcentajeControllers) {
      controller.dispose();
    }
    for (final controller in _descripcionControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _addEmprendedor() {
    setState(() {
      _emprendedoresParticipantes.add({
        'emprendedor_id': null,
        'emprendedor_nombre': '',
        'rol': 'colaborador',
        'porcentaje_ganancia': 0.0,
        'descripcion_participacion': '',
        'es_organizador_principal': false,
      });
      
      // Agregar controllers para el nuevo emprendedor
      _porcentajeControllers.add(TextEditingController(text: '0.0'));
      _descripcionControllers.add(TextEditingController());
    });
  }

  void _removeEmprendedor(int index) {
    setState(() {
      _emprendedoresParticipantes.removeAt(index);
      
      // Remover controllers correspondientes
      if (index < _porcentajeControllers.length) {
        _porcentajeControllers[index].dispose();
        _porcentajeControllers.removeAt(index);
      }
      if (index < _descripcionControllers.length) {
        _descripcionControllers[index].dispose();
        _descripcionControllers.removeAt(index);
      }
    });
  }

  void _updateEmprendedor(int index, String field, dynamic value) {
    setState(() {
      _emprendedoresParticipantes[index][field] = value;
      
      // Si se seleccionó un emprendedor, obtener su nombre
      if (field == 'emprendedor_id' && value != null) {
        final emprendedor = _emprendedores.firstWhere(
          (e) => e['id'] == value,
          orElse: () => {},
        );
        if (emprendedor.isNotEmpty) {
          _emprendedoresParticipantes[index]['emprendedor_nombre'] = emprendedor['nombre'] ?? '';
        }
      }
      
      // Si se marcó como organizador principal, desmarcar los demás
      if (field == 'es_organizador_principal' && value == true) {
        for (int i = 0; i < _emprendedoresParticipantes.length; i++) {
          if (i != index) {
            _emprendedoresParticipantes[i]['es_organizador_principal'] = false;
          }
        }
      }
    });
  }

  double _getTotalPorcentaje() {
    return _emprendedoresParticipantes.fold(0.0, (sum, emp) => sum + (emp['porcentaje_ganancia'] ?? 0.0));
  }

  bool _hasOrganizadorPrincipal() {
    return _emprendedoresParticipantes.any((emp) => emp['es_organizador_principal'] == true);
  }

  Future<void> _pickImage(bool isPrincipal) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isPrincipal) {
          _imagenPrincipal = File(image.path);
        } else {
          if (_imagenesGaleria.length < 10) {
            _imagenesGaleria.add(File(image.path));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Máximo 10 imágenes en la galería')),
            );
          }
        }
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() {
      _imagenesGaleria.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_hasOrganizadorPrincipal()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Debes agregar al menos un emprendedor organizador'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final planData = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'que_incluye': _queIncluyeController.text.trim(),
        'requerimientos': _requerimientosController.text.trim(),
        'que_llevar': _queLlevarController.text.trim(),
        'estado': _estado,
        'dificultad': _dificultad,
        'es_publico': _esPublico,
        'duracion_dias': _duracionDias,
        'capacidad': _capacidad,
        'precio_total': _precioTotal,
        'emprendedor_id': _selectedEmprendedorPrincipal?['id'],
        'emprendedores': _emprendedoresParticipantes,
      };

      if (isEditing) {
        // Actualizar plan existente
        await _dashboardService.updatePlan(widget.plan!['id'], planData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Crear nuevo plan
        await _dashboardService.createPlan(planData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Plan' : 'Nuevo Plan'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información Básica
                  _buildSection(
                    'Información Básica',
                    'Datos principales del plan turístico',
                    [
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Plan *',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Tour Mágico por el Lago Titicaca',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el nombre del plan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Emprendedor Principal (Legacy)
                      DropdownButtonFormField<int>(
                        value: _selectedEmprendedorPrincipal?['id'],
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Seleccionar emprendedor...'),
                          ),
                          ..._emprendedores.map((emp) => DropdownMenuItem(
                            value: emp['id'],
                            child: Text(emp['nombre'] ?? 'Sin nombre'),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              _selectedEmprendedorPrincipal = _emprendedores.firstWhere(
                                (e) => e['id'] == value,
                                orElse: () => {},
                              );
                              
                              // Verificar si el emprendedor ya está en la lista de participantes
                              final emprendedorExiste = _emprendedoresParticipantes.any(
                                (emp) => emp['emprendedor_id'] == value
                              );
                              
                              // Si no existe, agregarlo como organizador principal
                              if (!emprendedorExiste && _selectedEmprendedorPrincipal != null && _selectedEmprendedorPrincipal!.isNotEmpty) {
                                _emprendedoresParticipantes.add({
                                  'emprendedor_id': value,
                                  'emprendedor_nombre': _selectedEmprendedorPrincipal!['nombre'] ?? '',
                                  'rol': 'organizador',
                                  'porcentaje_ganancia': 100.0,
                                  'descripcion_participacion': 'Organizador principal del plan',
                                  'es_organizador_principal': true,
                                });
                              }
                            } else {
                              _selectedEmprendedorPrincipal = null;
                            }
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Emprendedor Principal (Legacy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción *',
                          border: OutlineInputBorder(),
                          hintText: 'Describe la experiencia que ofrece este plan...',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese la descripción del plan';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _queIncluyeController,
                        decoration: const InputDecoration(
                          labelText: 'Qué Incluye',
                          border: OutlineInputBorder(),
                          hintText: 'Alojamiento, alimentación, transporte, guía, etc.',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Duración (días)'),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_duracionDias > 1) {
                                          setState(() => _duracionDias--);
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$_duracionDias',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => _duracionDias++);
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Capacidad'),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (_capacidad > 1) {
                                          setState(() => _capacidad--);
                                        }
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '$_capacidad',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => _capacidad++);
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        initialValue: _precioTotal.toStringAsFixed(2),
                        decoration: const InputDecoration(
                          labelText: 'Precio Total (S/)',
                          border: OutlineInputBorder(),
                          prefixText: 'S/ ',
                          hintText: '450.00',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el precio';
                          }
                          final precio = double.tryParse(value);
                          if (precio == null || precio < 0) {
                            return 'Precio debe ser mayor o igual a 0';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _precioTotal = double.tryParse(value) ?? 0.0;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _dificultad,
                        items: _dificultadOptions
                            .map((dificultad) => DropdownMenuItem(
                                  value: dificultad,
                                  child: Text(_dificultadLabels[dificultad]!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _dificultad = value ?? 'moderado');
                        },
                        decoration: const InputDecoration(
                          labelText: 'Dificultad',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _requerimientosController,
                        decoration: const InputDecoration(
                          labelText: 'Requerimientos',
                          border: OutlineInputBorder(),
                          hintText: 'Requisitos físicos, edad mínima, etc.',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _queLlevarController,
                        decoration: const InputDecoration(
                          labelText: 'Qué Llevar',
                          border: OutlineInputBorder(),
                          hintText: 'Ropa, equipo, documentos necesarios',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Plan público'),
                        subtitle: const Text('Visible para todos los usuarios'),
                        value: _esPublico,
                        onChanged: (value) {
                          setState(() => _esPublico = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _estado,
                        items: _estadoOptions
                            .map((estado) => DropdownMenuItem(
                                  value: estado,
                                  child: Text(_estadoLabels[estado]!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _estado = value ?? 'activo');
                        },
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Emprendedores Participantes
                  _buildSection(
                    'Emprendedores Participantes',
                    'Gestiona los emprendedores que participan en este plan y sus roles',
                    [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Emprendedores del Plan',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: _addEmprendedor,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Emprendedor'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (_emprendedoresParticipantes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No hay emprendedores agregados',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      
                      ..._emprendedoresParticipantes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final emprendedor = entry.value;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Emprendedor ${index + 1} ${emprendedor['es_organizador_principal'] == true ? 'Organizador Principal' : ''}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeEmprendedor(index),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                DropdownButtonFormField<int>(
                                  value: emprendedor['emprendedor_id'],
                                  items: [
                                    const DropdownMenuItem(
                                      value: null,
                                      child: Text('Seleccionar emprendedor...'),
                                    ),
                                    ..._emprendedores.map((emp) {
                                      final emprendedorId = emp['id'];
                                      final isSelectedInOtherDropdowns = _emprendedoresParticipantes
                                          .asMap()
                                          .entries
                                          .where((entry) => entry.key != index)
                                          .any((entry) => entry.value['emprendedor_id'] == emprendedorId);
                                      
                                      return DropdownMenuItem(
                                        value: emp['id'],
                                        child: Text(
                                          '${emp['nombre'] ?? 'Sin nombre'}${isSelectedInOtherDropdowns && emprendedor['emprendedor_id'] != emprendedorId ? ' (Ya seleccionado)' : ''}',
                                          style: TextStyle(
                                            color: isSelectedInOtherDropdowns && emprendedor['emprendedor_id'] != emprendedorId 
                                                ? Colors.grey 
                                                : null,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                  onChanged: (value) {
                                    // Verificar si el emprendedor ya está seleccionado en otro dropdown
                                    if (value != null) {
                                      final isAlreadySelected = _emprendedoresParticipantes
                                          .asMap()
                                          .entries
                                          .where((entry) => entry.key != index)
                                          .any((entry) => entry.value['emprendedor_id'] == value);
                                      
                                      if (isAlreadySelected) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Este emprendedor ya está seleccionado en otro campo'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }
                                    }
                                    _updateEmprendedor(index, 'emprendedor_id', value);
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Emprendedor',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: emprendedor['rol'],
                                        items: _rolOptions
                                            .map((rol) => DropdownMenuItem(
                                                  value: rol,
                                                  child: Text(rol == 'organizador' ? 'Organizador' : 'Colaborador'),
                                                ))
                                            .toList(),
                                        onChanged: (value) => _updateEmprendedor(index, 'rol', value),
                                        decoration: const InputDecoration(
                                          labelText: 'Rol',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: index < _porcentajeControllers.length 
                                            ? _porcentajeControllers[index] 
                                            : null,
                                        decoration: const InputDecoration(
                                          labelText: 'Porcentaje Ganancia (%)',
                                          border: OutlineInputBorder(),
                                          suffixText: '%',
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          final porcentaje = double.tryParse(value) ?? 0.0;
                                          _updateEmprendedor(index, 'porcentaje_ganancia', porcentaje);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                Text(
                                  'Total actual: ${_getTotalPorcentaje().toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: _getTotalPorcentaje() > 100 ? Colors.red : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: index < _descripcionControllers.length 
                                      ? _descripcionControllers[index] 
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Descripción de Participación',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                  onChanged: (value) => _updateEmprendedor(index, 'descripcion_participacion', value),
                                ),
                                const SizedBox(height: 16),
                                
                                SwitchListTile(
                                  title: const Text('Es el organizador principal del plan'),
                                  value: emprendedor['es_organizador_principal'] ?? false,
                                  onChanged: (value) => _updateEmprendedor(index, 'es_organizador_principal', value),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      
                      if (!_hasOrganizadorPrincipal())
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⚠️ Debes agregar al menos un emprendedor organizador',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Imágenes
                  _buildSection(
                    'Imágenes',
                    'Sube imágenes atractivas del plan',
                    [
                      // Imagen Principal
                      const Text(
                        'Imagen Principal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_imagenPrincipal != null)
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_imagenPrincipal!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () => setState(() => _imagenPrincipal = null),
                                icon: const Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 8),
                              Text(
                                'Seleccionar archivo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(true),
                        icon: const Icon(Icons.upload),
                        label: const Text('Seleccionar archivo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Galería de Imágenes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Galería de Imágenes (máximo 10)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_imagenesGaleria.length}/10',
                            style: TextStyle(
                              color: _imagenesGaleria.length >= 10 ? Colors.red : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (_imagenesGaleria.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: _imagenesGaleria.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_imagenesGaleria[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    onPressed: () => _removeGalleryImage(index),
                                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(24, 24),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _imagenesGaleria.length < 10 ? () => _pickImage(false) : null,
                        icon: const Icon(Icons.upload),
                        label: const Text('Elegir archivos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(isEditing ? 'Guardar Cambios' : 'Crear Plan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
} 