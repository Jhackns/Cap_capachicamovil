import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      _controllers[f] = TextEditingController(text: widget.initialData?[f]?.toString() ?? '');
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
      List<String> toList(String value) {
        if (value.isEmpty) return [];
        return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
      data['metodos_pago'] = toList(_controllers['metodos_pago']?.text ?? '');
      data['imagenes'] = toList(_controllers['imagenes']?.text ?? '');
      data['certificaciones'] = toList(_controllers['certificaciones']?.text ?? '');
      data['idiomas_hablados'] = toList(_controllers['idiomas_hablados']?.text ?? '');
      data['opciones_acceso'] = toList(_controllers['opciones_acceso']?.text ?? '');
      // Números
      data['capacidad_aforo'] = int.tryParse(_controllers['capacidad_aforo']?.text ?? '');
      data['numero_personas_atiende'] = int.tryParse(_controllers['numero_personas_atiende']?.text ?? '');
      data['asociacion_id'] = int.tryParse(_controllers['asociacion_id']?.text ?? '');
      // Booleanos
      data['estado'] = _estado;
      data['facilidades_discapacidad'] = _facilidadesDiscapacidad;
      // Limpiar campos vacíos
      data.removeWhere((k, v) => v == null || (v is String && v.isEmpty));
      widget.onSubmit(data);
    }
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
              _buildTextField('tipo_servicio', 'Tipo de Servicio*'),
              _buildTextField('descripcion', 'Descripción', maxLines: 3),
              _buildTextField('categoria', 'Categoría*'),
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
              _buildTextField('asociacion_id', 'ID Asociación', keyboardType: TextInputType.number),
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

  Widget _buildTextField(String key, String label, {int maxLines = 1, TextInputType? keyboardType, List<String>? autofillHints}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: (value) {
          if ((key == 'nombre' || key == 'tipo_servicio' || key == 'ubicacion' || key == 'telefono' || key == 'email' || key == 'categoria') && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio';
          }
          if (key == 'email' && value != null && value.isNotEmpty && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+").hasMatch(value)) {
            return 'Correo inválido';
          }
          return null;
        },
      ),
    );
  }
} 