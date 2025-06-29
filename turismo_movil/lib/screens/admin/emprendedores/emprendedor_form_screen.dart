import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class EmprendedorFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final void Function(Map<String, dynamic>) onSubmit;
  final bool isEdit;

  const EmprendedorFormScreen({Key? key, this.initialData, required this.onSubmit, this.isEdit = false}) : super(key: key);

  @override
  State<EmprendedorFormScreen> createState() => _EmprendedorFormScreenState();
}

class _EmprendedorFormScreenState extends State<EmprendedorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _estado = true;
  bool _facilidadesDiscapacidad = false;
  // Sugerencias para categorías y tipo de servicio
  final List<String> _categoriasSugeridas = [
    'Alojamiento', 'Alimentación', 'Artesanía', 'Transporte', 'Actividades'
  ];
  final List<String> _tiposServicioSugeridos = [
    'Alojamiento', 'Restaurante', 'Guía', 'Transporte', 'Tienda', 'Otro'
  ];
  // Simulación de asociaciones (en producción, cargar desde provider o API)
  final List<Map<String, dynamic>> _asociaciones = [
    {'id': 1, 'nombre': 'Asociación de Turismo Vivencial Llachón'},
    {'id': 2, 'nombre': 'Asociación de Artesanos Capachica'},
    {'id': 3, 'nombre': 'Asociación de Transporte Turístico'},
  ];
  // Errores de validación en tiempo real
  final Map<String, String?> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    final fields = [
      'nombre', 'tipo_servicio', 'descripcion', 'ubicacion', 'telefono', 'email', 'pagina_web',
      'horario_atencion', 'precio_rango', 'metodos_pago', 'capacidad_aforo', 'numero_personas_atiende',
      'comentarios_resenas', 'imagenes', 'categoria', 'certificaciones', 'idiomas_hablados',
      'opciones_acceso', 'asociacion_id'
    ];
    for (var f in fields) {
      var value = widget.initialData?[f];
      if (value is List) {
        _controllers[f] = TextEditingController(text: value.join(', '));
      } else {
        _controllers[f] = TextEditingController(text: value?.toString() ?? '');
      }
    }
    _estado = widget.initialData?['estado'] ?? true;
    _facilidadesDiscapacidad = widget.initialData?['facilidades_discapacidad'] ?? false;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{};
      _controllers.forEach((k, v) => data[k] = v.text.trim());
      // Transformar arrays
      List<String> toList(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        }
        if (value is String && value.trim().startsWith('[') && value.trim().endsWith(']')) {
          try {
            final decoded = List<String>.from(jsonDecode(value));
            return decoded;
          } catch (_) {}
        }
        if (value is String) {
          return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        return [];
      }
      data['metodos_pago'] = toList(_controllers['metodos_pago']?.text ?? '');
      data['imagenes'] = toList(_controllers['imagenes']?.text ?? '');
      data['certificaciones'] = toList(_controllers['certificaciones']?.text ?? '');
      data['idiomas_hablados'] = toList(_controllers['idiomas_hablados']?.text ?? '');
      data['opciones_acceso'] = _controllers['opciones_acceso']?.text.trim() ?? '';
      // Números
      data['capacidad_aforo'] = int.tryParse(_controllers['capacidad_aforo']?.text ?? '');
      data['numero_personas_atiende'] = int.tryParse(_controllers['numero_personas_atiende']?.text ?? '');
      data['asociacion_id'] = int.tryParse(_controllers['asociacion_id']?.text ?? '');
      // Booleanos
      data['estado'] = _estado;
      data['facilidades_discapacidad'] = _facilidadesDiscapacidad;
      // Limpiar campos vacíos
      data.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
      // LOGS DETALLADOS
      print('=== DATOS A ENVIAR ===');
      print('JSON: ' + data.toString());
      print('imagenes: ' + data['imagenes'].toString());
      print('certificaciones: ' + data['certificaciones'].toString());
      print('metodos_pago: ' + data['metodos_pago'].toString());
      print('idiomas_hablados: ' + data['idiomas_hablados'].toString());
      print('opciones_acceso: ' + data['opciones_acceso'].toString());
      widget.onSubmit(data);
    }
  }

  void _validateField(String key, String value) {
    String? error;
    switch (key) {
      case 'nombre':
      case 'tipo_servicio':
      case 'ubicacion':
      case 'telefono':
      case 'email':
      case 'categoria':
        if (value.isEmpty) error = 'Este campo es obligatorio';
        if (key == 'email' && value.isNotEmpty && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(value)) {
          error = 'Correo inválido';
        }
        break;
      case 'asociacion_id':
        if (value.isEmpty) error = 'Seleccione una asociación';
        else if (!_asociaciones.any((a) => a['id'].toString() == value)) error = 'ID de asociación inválido';
        break;
    }
    setState(() {
      _fieldErrors[key] = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Editar Emprendedor' : 'Nuevo Emprendedor'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Datos Básicos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF9C27B0))),
              const SizedBox(height: 8),
              _buildTextField('nombre', 'Nombre*', autofillHints: [AutofillHints.name]),
              _buildTextField('tipo_servicio', 'Tipo de Servicio*', suggestions: _tiposServicioSugeridos),
              _buildTextField('descripcion', 'Descripción', maxLines: 3),
              _buildTextField('categoria', 'Categoría*', suggestions: _categoriasSugeridas),
              _buildTextField('ubicacion', 'Ubicación*', autofillHints: [AutofillHints.fullStreetAddress]),
              const SizedBox(height: 16),
              const Text('Contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF9C27B0))),
              const SizedBox(height: 8),
              _buildTextField('telefono', 'Teléfono*', keyboardType: TextInputType.phone, autofillHints: [AutofillHints.telephoneNumber]),
              _buildTextField('email', 'Email*', keyboardType: TextInputType.emailAddress, autofillHints: [AutofillHints.email]),
              _buildTextField('pagina_web', 'Página Web', keyboardType: TextInputType.url),
              const SizedBox(height: 16),
              const Text('Detalles del Servicio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF9C27B0))),
              const SizedBox(height: 8),
              _buildTextField('horario_atencion', 'Horario de Atención'),
              _buildTextField('precio_rango', 'Precio/Rango'),
              _buildTextField('metodos_pago', 'Métodos de Pago (separados por coma)'),
              _buildTextField('capacidad_aforo', 'Capacidad/Aforo'),
              _buildTextField('numero_personas_atiende', 'N° Personas que Atiende'),
              _buildTextField('comentarios_resenas', 'Comentarios/Reseñas'),
              _buildTextField('imagenes', 'URLs de Imágenes (separadas por coma)'),
              _buildTextField('certificaciones', 'Certificaciones (separadas por coma)'),
              _buildTextField('idiomas_hablados', 'Idiomas Hablados (separados por coma)'),
              _buildTextField('opciones_acceso', 'Opciones de Acceso (separadas por coma)'),
              _buildTextField('asociacion_id', 'ID Asociación'),
              SwitchListTile(
                title: const Text('¿Activo?'),
                value: _estado,
                onChanged: (v) => setState(() => _estado = v),
                activeColor: const Color(0xFF9C27B0),
              ),
              SwitchListTile(
                title: const Text('¿Facilidades para Discapacidad?'),
                value: _facilidadesDiscapacidad,
                onChanged: (v) => setState(() => _facilidadesDiscapacidad = v),
                activeColor: const Color(0xFF9C27B0),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(widget.isEdit ? 'Guardar Cambios' : 'Crear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9C27B0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String key, String label, {int maxLines = 1, TextInputType? keyboardType, List<String>? autofillHints, bool isDropdown = false, List<String>? suggestions}) {
    if (key == 'categoria' && suggestions != null) {
      final currentSuggestions = List<String>.from(suggestions);
      final currentValue = _controllers[key]?.text;
      if (currentValue != null && currentValue.isNotEmpty && !currentSuggestions.contains(currentValue)) {
        currentSuggestions.insert(0, currentValue);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: currentValue?.isNotEmpty == true ? currentValue : null,
          items: currentSuggestions.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) {
            _controllers[key]?.text = val ?? '';
            _validateField(key, val ?? '');
          },
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _fieldErrors[key],
          ),
          validator: (value) => _fieldErrors[key],
        ),
      );
    }
    if (key == 'tipo_servicio' && suggestions != null) {
      final currentSuggestions = List<String>.from(suggestions);
      final currentValue = _controllers[key]?.text;
      if (currentValue != null && currentValue.isNotEmpty && !currentSuggestions.contains(currentValue)) {
        currentSuggestions.insert(0, currentValue);
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: currentValue?.isNotEmpty == true ? currentValue : null,
          items: currentSuggestions.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
          onChanged: (val) {
            _controllers[key]?.text = val ?? '';
            _validateField(key, val ?? '');
          },
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _fieldErrors[key],
          ),
          validator: (value) => _fieldErrors[key],
        ),
      );
    }
    if (key == 'asociacion_id') {
      final currentValue = _controllers[key]?.text;
      final isValueValid = currentValue != null &&
          currentValue.isNotEmpty &&
          _asociaciones.any((a) => a['id'].toString() == currentValue);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: DropdownButtonFormField<String>(
          value: isValueValid ? currentValue : null,
          items: _asociaciones.map((a) => DropdownMenuItem(value: a['id'].toString(), child: Text(a['nombre']))).toList(),
          onChanged: (val) {
            _controllers[key]?.text = val ?? '';
            _validateField(key, val ?? '');
          },
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            errorText: _fieldErrors[key],
          ),
          validator: (value) => _fieldErrors[key],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          errorText: _fieldErrors[key],
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        onChanged: (val) => _validateField(key, val),
        validator: (value) => _fieldErrors[key],
      ),
    );
  }
} 