import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../blocs/asociaciones/asociaciones_bloc.dart';
import '../../../blocs/asociaciones/asociaciones_event.dart';
import '../../../blocs/asociaciones/asociaciones_state.dart';
import '../../../models/asociacion.dart';
import '../../../services/municipalidad_service.dart';

class AsociacionFormScreen extends StatefulWidget {
  final Asociacion? asociacion;
  
  const AsociacionFormScreen({Key? key, this.asociacion}) : super(key: key);

  @override
  State<AsociacionFormScreen> createState() => _AsociacionFormScreenState();
}

class _AsociacionFormScreenState extends State<AsociacionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  bool _isActive = true;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isLoadingMunicipalidades = false;
  List<Map<String, dynamic>> _municipalidades = [];
  Map<String, dynamic>? _selectedMunicipalidad;
  final MunicipalidadService _municipalidadService = MunicipalidadService();

  @override
  void initState() {
    super.initState();
    _loadMunicipalidades();
    if (widget.asociacion != null) {
      _nameController.text = widget.asociacion!.nombre;
      _descriptionController.text = widget.asociacion!.descripcion ?? '';
      _phoneController.text = widget.asociacion!.telefono ?? '';
      _emailController.text = widget.asociacion!.email ?? '';
      _latitudeController.text = widget.asociacion!.latitud?.toString() ?? '-15.645000';
      _longitudeController.text = widget.asociacion!.longitud?.toString() ?? '-69.834500';
      _isActive = widget.asociacion!.estado;
    } else {
      // Valores por defecto para nueva asociación
      _latitudeController.text = '-15.645000';
      _longitudeController.text = '-69.834500';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _loadMunicipalidades() async {
    setState(() {
      _isLoadingMunicipalidades = true;
    });

    try {
      final municipalidades = await _municipalidadService.getMunicipalidades();
      setState(() {
        _municipalidades = municipalidades;
        // Seleccionar la municipalidad correcta
        if (widget.asociacion != null) {
          // Si estamos editando, buscar la municipalidad de la asociación
          _selectedMunicipalidad = _municipalidades.firstWhere(
            (m) => m['id'] == widget.asociacion!.municipalidadId,
            orElse: () => _municipalidades.isNotEmpty ? _municipalidades.first : {},
          );
        } else {
          // Si es nueva, seleccionar la primera municipalidad por defecto
          if (_municipalidades.isNotEmpty) {
            _selectedMunicipalidad = _municipalidades.first;
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar municipalidades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingMunicipalidades = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      final file = File(image.path);
      final sizeInBytes = await file.length();
      final sizeInMb = sizeInBytes / (1024 * 1024);
      
      if (sizeInMb > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen debe ser menor a 2MB'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _selectedImage = file;
      });
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedMunicipalidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar una municipalidad'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final asociacionData = {
      'nombre': _nameController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'telefono': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'latitud': double.tryParse(_latitudeController.text) ?? -15.645000,
      'longitud': double.tryParse(_longitudeController.text) ?? -69.834500,
      'municipalidad_id': _selectedMunicipalidad!['id'],
      'estado': _isActive,
      'imagen': _selectedImage,
    };

    if (widget.asociacion != null) {
      context.read<AsociacionesBloc>().add(UpdateAsociacion(widget.asociacion!.id, asociacionData));
    } else {
      context.read<AsociacionesBloc>().add(CreateAsociacion(asociacionData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AsociacionesBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.asociacion != null ? 'Editar Asociación' : 'Crear Asociación'),
          backgroundColor: const Color(0xFF9C27B0),
          foregroundColor: Colors.white,
        ),
        body: BlocListener<AsociacionesBloc, AsociacionesState>(
          listener: (context, state) {
            if (state is AsociacionOperationSuccess) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is AsociacionOperationError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.group_work_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.asociacion != null ? 'Editar Asociación' : 'Crear Asociación',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete la información de la asociación',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  _buildSectionTitle('Nombre'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la asociación',
                      hintText: 'Ej: Asociación de Turismo Capachica',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  _buildSectionTitle('Descripción'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción breve de la asociación',
                      hintText: 'Describa brevemente la asociación...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Municipalidad
                  _buildSectionTitle('Municipalidad'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _isLoadingMunicipalidades
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : DropdownButtonFormField<Map<String, dynamic>>(
                            value: _selectedMunicipalidad,
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar municipalidad',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            items: _municipalidades.map((municipalidad) {
                              return DropdownMenuItem(
                                value: municipalidad,
                                child: Text(municipalidad['nombre'] ?? 'Sin nombre'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMunicipalidad = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Debe seleccionar una municipalidad';
                              }
                              return null;
                            },
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Imagen
                  _buildSectionTitle('Imagen'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Subir imagen',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PNG, JPG, GIF hasta 2MB',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Ubicación Geográfica
                  _buildSectionTitle('Ubicación Geográfica'),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccione la ubicación de la asociación.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                            hintText: '-15.645000',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lat = double.tryParse(value);
                              if (lat == null || lat < -90 || lat > 90) {
                                return 'Latitud inválida (-90 a 90)';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Longitud',
                            hintText: '-69.834500',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lng = double.tryParse(value);
                              if (lng == null || lng < -180 || lng > 180) {
                                return 'Longitud inválida (-180 a 180)';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Información de contacto
                  _buildSectionTitle('Información de Contacto'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            hintText: '999 999 999',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'ejemplo@correo.com',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Email inválido';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Estado
                  _buildSectionTitle('Estado'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      title: const Text('Activo'),
                      subtitle: const Text('Indica si la asociación está activa actualmente'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                      activeColor: const Color(0xFF9C27B0),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF9C27B0)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Color(0xFF9C27B0)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9C27B0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  widget.asociacion != null ? 'Actualizar' : 'Crear',
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF9C27B0),
      ),
    );
  }
} 