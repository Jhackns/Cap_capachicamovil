import 'package:flutter/material.dart';

class CategoriaFormScreen extends StatefulWidget {
  final String? initialNombre;
  final String? initialDescripcion;
  final String? initialIconoUrl;
  final String? initialImagenUrl;
  final void Function(String nombre, String descripcion, String iconoUrl, String imagenUrl) onSubmit;
  final VoidCallback? onCancel;
  final bool isEdit;

  const CategoriaFormScreen({
    Key? key,
    this.initialNombre,
    this.initialDescripcion,
    this.initialIconoUrl,
    this.initialImagenUrl,
    required this.onSubmit,
    this.onCancel,
    this.isEdit = false,
  }) : super(key: key);

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _iconoUrlController;
  late TextEditingController _imagenUrlController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.initialNombre ?? '');
    _descripcionController = TextEditingController(text: widget.initialDescripcion ?? '');
    _iconoUrlController = TextEditingController(text: widget.initialIconoUrl ?? '');
    _imagenUrlController = TextEditingController(text: widget.initialImagenUrl ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _iconoUrlController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconUrl = _iconoUrlController.text.trim();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onCancel != null) {
              widget.onCancel!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(widget.isEdit ? 'Editar Categoría' : 'Crear Categoría'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEdit ? 'Editar Categoría' : 'Nueva Categoría',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text('Nombre', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                ),
                const SizedBox(height: 18),
                Text('Descripción', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    hintText: 'Descripción breve',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 18),
                Text('URL del Icono', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _iconoUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://.../icon.png',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Text('Vista previa del icono', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: iconUrl.isEmpty
                        ? const Icon(Icons.image_outlined, size: 48, color: Colors.grey)
                        : Image.network(
                            iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            widget.onSubmit(
                              _nombreController.text.trim(),
                              _descripcionController.text.trim(),
                              _iconoUrlController.text.trim(),
                              '', // imagenUrl ya no se usa
                            );
                          }
                        },
                        child: Text(widget.isEdit ? 'Guardar' : 'Crear'),
                      ),
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
} 