import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../models/servicio.dart';
import '../../../services/servicio_service.dart';
import '../../../widgets/horario_selector.dart';

class ServicioFormScreen extends StatefulWidget {
  final Servicio? servicio;

  const ServicioFormScreen({Key? key, this.servicio}) : super(key: key);

  @override
  State<ServicioFormScreen> createState() => _ServicioFormScreenState();
}

class _ServicioFormScreenState extends State<ServicioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _ubicacionReferenciaController = TextEditingController();
  
  int? _selectedEmprendedorId;
  List<int> _selectedCategorias = [];
  bool _estado = true;
  int _capacidad = 1;
  
  List<Map<String, dynamic>> _emprendedores = [];
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _horarios = [];
  List<File> _imagenes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  final ServicioService _servicioService = ServicioService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.servicio != null) {
      _loadServicioData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final emprendedores = await _servicioService.getEmprendedores();
      final categorias = await _servicioService.getCategorias();
      setState(() {
        _emprendedores = emprendedores;
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _loadServicioData() {
    final servicio = widget.servicio!;
    _nombreController.text = servicio.nombre;
    _descripcionController.text = servicio.descripcion;
    _precioController.text = servicio.precio.toString();
    _estado = servicio.estado;
    _capacidad = servicio.capacidad;
    
    if (servicio.latitud != null) {
      _latitudController.text = servicio.latitud!.toString();
    }
    if (servicio.longitud != null) {
      _longitudController.text = servicio.longitud!.toString();
    }
    if (servicio.ubicacionReferencia != null) {
      _ubicacionReferenciaController.text = servicio.ubicacionReferencia!;
    }
    
    // Cargar emprendedor
    _selectedEmprendedorId = servicio.emprendedorId;
    
    // Cargar categorías
    _selectedCategorias = servicio.categoriaIds;
    
    // Cargar horarios
    _horarios = List.from(servicio.horarios);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagenes.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagenes.removeAt(index);
    });
  }

  void _onHorariosChanged(List<Map<String, dynamic>> horarios) {
    setState(() {
      _horarios = horarios;
    });
  }

  Future<void> _saveServicio() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmprendedorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un emprendedor'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_selectedCategorias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una categoría'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'nombre': _nombreController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'precio_referencial': double.parse(_precioController.text),
        'emprendedor_id': _selectedEmprendedorId,
        'categorias': _selectedCategorias,
        'estado': _estado,
        'capacidad': _capacidad,
        'latitud': _latitudController.text.isNotEmpty ? double.parse(_latitudController.text) : null,
        'longitud': _longitudController.text.isNotEmpty ? double.parse(_longitudController.text) : null,
        'ubicacion_referencia': _ubicacionReferenciaController.text.trim(),
        'horarios': _horarios.where((h) => h['activo'] == true).toList(),
      };

      print('📤 Enviando datos del servicio: $data');

      Map<String, dynamic> result;
      if (widget.servicio != null) {
        result = await _servicioService.updateServicio(widget.servicio!.id, data);
      } else {
        result = await _servicioService.createServicio(data);
      }

      if (result.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.servicio != null ? 'Servicio actualizado exitosamente' : 'Servicio creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('No se pudo guardar el servicio');
      }
    } catch (e) {
      print('❌ Error al guardar servicio: $e');
      String errorMessage = 'Error al guardar: $e';
      
      // Si es un error de validación, mostrar información más detallada
      if (e.toString().contains('Error de validación:')) {
        errorMessage = e.toString().replaceAll('Error de validación: ', '');
        errorMessage = 'Errores de validación:\n$errorMessage';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _ubicacionReferenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicio != null ? 'Editar Servicio' : 'Nuevo Servicio'),
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
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildCapacitySection(),
                    const SizedBox(height: 24),
                    _buildEmprendedorSection(),
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 24),
                    _buildLocationSection(),
                    const SizedBox(height: 24),
                    _buildHorariosSection(),
                    const SizedBox(height: 24),
                    _buildCategoriesSection(),
                    const SizedBox(height: 24),
                    _buildImagesSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
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
            const Text(
              'Información Básica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Servicio *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.miscellaneous_services),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
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
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _precioController,
              decoration: const InputDecoration(
                labelText: 'Precio (S/.) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El precio es requerido';
                }
                final precio = double.tryParse(value);
                if (precio == null || precio < 0) {
                  return 'Ingresa un precio válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Capacidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Capacidad del servicio',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_capacidad > 1) {
                            setState(() => _capacidad--);
                          }
                        },
                        icon: const Icon(Icons.remove),
                        color: const Color(0xFF9C27B0),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '$_capacidad',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _capacidad++);
                        },
                        icon: const Icon(Icons.add),
                        color: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmprendedorSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emprendedor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedEmprendedorId,
              decoration: const InputDecoration(
                labelText: 'Emprendedor *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _emprendedores.map((e) {
                return DropdownMenuItem<int>(
                  value: e['id'] as int,
                  child: Text(e['nombre'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEmprendedorId = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Servicio Activo'),
              subtitle: const Text('El servicio estará disponible para los usuarios'),
              value: _estado,
              onChanged: (value) {
                setState(() => _estado = value);
              },
              activeColor: const Color(0xFF9C27B0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación Geográfica',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudController,
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Latitud debe estar entre -90 y 90';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudController,
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Longitud debe estar entre -180 y 180';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionReferenciaController,
              decoration: const InputDecoration(
                labelText: 'Referencia de ubicación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
                hintText: 'Ej: Comunidad Cotos, a 1km del centro',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.map, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mapa geográfico (en desarrollo)',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorariosSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: HorarioSelector(
          horarios: _horarios,
          onHorariosChanged: _onHorariosChanged,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Categorías *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((categoria) {
                final categoriaId = categoria['id'] as int;
                final isSelected = _selectedCategorias.contains(categoriaId);
                return FilterChip(
                  label: Text(categoria['nombre'] ?? ''),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategorias.add(categoriaId);
                      } else {
                        _selectedCategorias.remove(categoriaId);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF9C27B0).withOpacity(0.2),
                  checkmarkColor: const Color(0xFF9C27B0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imágenes del Servicio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Agregar Imagen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_imagenes.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _imagenes.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imagenes[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
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
            onPressed: _isSaving ? null : _saveServicio,
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
                : Text(widget.servicio != null ? 'Actualizar' : 'Crear'),
          ),
        ),
      ],
    );
  }
} 