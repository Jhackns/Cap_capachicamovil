import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/municipalidad/municipalidad_bloc.dart';
import '../../models/municipalidad.dart';

class MunicipalidadFormScreen extends StatefulWidget {
  final Municipalidad? municipalidad;

  const MunicipalidadFormScreen({Key? key, this.municipalidad})
      : super(key: key);

  @override
  _MunicipalidadFormScreenState createState() =>
      _MunicipalidadFormScreenState();
}

class _MunicipalidadFormScreenState extends State<MunicipalidadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'nombre': TextEditingController(text: widget.municipalidad?.nombre),
      'descripcion':
          TextEditingController(text: widget.municipalidad?.descripcion),
      'red_facebook':
          TextEditingController(text: widget.municipalidad?.redFacebook),
      'red_instagram':
          TextEditingController(text: widget.municipalidad?.redInstagram),
      'red_youtube':
          TextEditingController(text: widget.municipalidad?.redYoutube),
      'coordenadas_x':
          TextEditingController(text: widget.municipalidad?.coordenadasX),
      'coordenadas_y':
          TextEditingController(text: widget.municipalidad?.coordenadasY),
      'frase': TextEditingController(text: widget.municipalidad?.frase),
      'comunidades':
          TextEditingController(text: widget.municipalidad?.comunidades),
      'historiafamilias':
          TextEditingController(text: widget.municipalidad?.historiafamilias),
      'historiacapachica':
          TextEditingController(text: widget.municipalidad?.historiacapachica),
      'comite': TextEditingController(text: widget.municipalidad?.comite),
      'mision': TextEditingController(text: widget.municipalidad?.mision),
      'vision': TextEditingController(text: widget.municipalidad?.vision),
      'valores': TextEditingController(text: widget.municipalidad?.valores),
      'ordenanzamunicipal': TextEditingController(
          text: widget.municipalidad?.ordenanzamunicipal),
      'alianzas': TextEditingController(text: widget.municipalidad?.alianzas),
      'correo': TextEditingController(text: widget.municipalidad?.correo),
      'horariodeatencion':
          TextEditingController(text: widget.municipalidad?.horariodeatencion),
    };
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data =
          _controllers.map((key, controller) => MapEntry(key, controller.text));

      if (widget.municipalidad == null) {
        context.read<MunicipalidadBloc>().add(AddMunicipalidad(data));
      } else {
        context
            .read<MunicipalidadBloc>()
            .add(UpdateMunicipalidad(widget.municipalidad!.id, data));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assert that the bloc is available (for easier debugging)
    assert(BlocProvider.of<MunicipalidadBloc>(context, listen: false) != null, 'MunicipalidadBloc not found in context. Make sure to use BlocProvider.value when navigating to this screen.');
    return BlocListener<MunicipalidadBloc, MunicipalidadState>(
      listener: (context, state) {
        if (state is MunicipalidadLoading) {
          setState(() => _isLoading = true);
        } else if (state is MunicipalidadOperationSuccess) {
          Navigator.of(context).pop(true); // Indicar que hubo un cambio
        } else if (state is MunicipalidadError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.municipalidad == null
              ? 'Nueva Municipalidad'
              : 'Editar Municipalidad'),
          backgroundColor: const Color(0xFF9C27B0),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key.replaceAll('_', ' ').capitalize(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (entry.key == 'nombre' &&
                            (value == null || value.isEmpty)) {
                          return 'El nombre es obligatorio';
                        }
                        if (entry.key == 'correo' &&
                            value!.isNotEmpty &&
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                          return 'Correo no válido';
                        }
                        return null;
                      },
                      maxLines: entry.key.contains('descripcion') ||
                              entry.key.contains('historia')
                          ? 3
                          : 1,
                      keyboardType: entry.key.contains('coordenadas')
                          ? TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.text,
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.municipalidad == null
                          ? 'Crear'
                          : 'Actualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1)}";
  }
} 