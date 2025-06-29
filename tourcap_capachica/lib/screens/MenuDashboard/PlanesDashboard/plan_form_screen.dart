import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/planes/planes_bloc.dart';
import '../../../blocs/planes/planes_event.dart';
import '../../../blocs/planes/planes_state.dart';

class PlanFormScreen extends StatefulWidget {
  final Map<String, dynamic>? plan;

  const PlanFormScreen({Key? key, this.plan}) : super(key: key);

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _queIncluyeController = TextEditingController();
  final _requerimientosController = TextEditingController();
  final _queLlevarController = TextEditingController();
  
  // Variables del formulario
  String _estado = 'borrador';
  String _dificultad = 'moderado';
  bool _esPublico = false;
  int _duracionDias = 1;
  int _capacidad = 1;
  double _precioTotal = 0.0;
  List<Map<String, dynamic>> _emprendedores = [];
  List<Map<String, dynamic>> _categorias = [];
  Map<String, dynamic>? _selectedEmprendedor;

  final List<String> _estadoOptions = ['borrador', 'activo', 'inactivo'];
  final List<String> _dificultadOptions = ['fácil', 'moderado', 'difícil'];
  final Map<String, String> _estadoLabels = {
    'borrador': 'Borrador',
    'activo': 'Activo',
    'inactivo': 'Inactivo',
  };
  final Map<String, String> _dificultadLabels = {
    'fácil': 'Fácil',
    'moderado': 'Moderado',
    'difícil': 'Difícil',
  };

  bool get isEditing => widget.plan != null;

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
      _estado = plan['estado'] ?? 'borrador';
      _dificultad = plan['dificultad'] ?? 'moderado';
      _esPublico = plan['es_publico'] ?? false;
      _duracionDias = plan['duracion_dias'] ?? 1;
      _capacidad = plan['capacidad'] ?? 1;
      _precioTotal = (plan['precio_total'] ?? 0.0).toDouble();
    }
  }

  void _loadData() {
    context.read<PlanesBloc>().add(LoadEmprendedores());
    context.read<PlanesBloc>().add(LoadCategorias());
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _queIncluyeController.dispose();
    _requerimientosController.dispose();
    _queLlevarController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

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
    };

    if (isEditing) {
      context.read<PlanesBloc>().add(UpdatePlan(widget.plan!['id'], planData));
    } else {
      context.read<PlanesBloc>().add(CreatePlan(planData));
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
      body: BlocListener<PlanesBloc, PlanesState>(
        listener: (context, state) {
          if (state is PlanCreated || state is PlanUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing ? 'Plan actualizado exitosamente' : 'Plan creado exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PlanesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EmprendedoresLoaded) {
            _emprendedores = state.emprendedores;
          } else if (state is CategoriasLoaded) {
            _categorias = state.categorias;
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica
                _buildSection(
                  'Información Básica',
                  [
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del plan *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el nombre del plan';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
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
                        labelText: '¿Qué incluye?',
                        border: OutlineInputBorder(),
                        helperText: 'Servicios, comidas, transporte, etc.',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Configuración del plan
                _buildSection(
                  'Configuración del Plan',
                  [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _estado,
                            items: _estadoOptions
                                .map((estado) => DropdownMenuItem(
                                      value: estado,
                                      child: Text(_estadoLabels[estado]!),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _estado = value ?? 'borrador');
                            },
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
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
                        ),
                      ],
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
                  ],
                ),
                const SizedBox(height: 24),

                // Detalles del plan
                _buildSection(
                  'Detalles del Plan',
                  [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _duracionDias.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Duración (días) *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese la duración';
                              }
                              final dias = int.tryParse(value);
                              if (dias == null || dias < 1) {
                                return 'Duración debe ser mayor a 0';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _duracionDias = int.tryParse(value) ?? 1;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: _capacidad.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Capacidad *',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingrese la capacidad';
                              }
                              final cap = int.tryParse(value);
                              if (cap == null || cap < 1) {
                                return 'Capacidad debe ser mayor a 0';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              _capacidad = int.tryParse(value) ?? 1;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _precioTotal.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Precio total (S/) *',
                        border: OutlineInputBorder(),
                        prefixText: 'S/ ',
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
                  ],
                ),
                const SizedBox(height: 24),

                // Información adicional
                _buildSection(
                  'Información Adicional',
                  [
                    TextFormField(
                      controller: _requerimientosController,
                      decoration: const InputDecoration(
                        labelText: 'Requerimientos',
                        border: OutlineInputBorder(),
                        helperText: 'Requisitos físicos, edad mínima, etc.',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _queLlevarController,
                      decoration: const InputDecoration(
                        labelText: '¿Qué llevar?',
                        border: OutlineInputBorder(),
                        helperText: 'Ropa, equipo, documentos necesarios',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isEditing ? 'Guardar Cambios' : 'Crear Plan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
} 