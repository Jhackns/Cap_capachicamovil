import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/resena_bloc/resena_bloc.dart';

class SubmitResenaWidget extends StatefulWidget {
  final String reservaId;
  final String alojamientoId;
  // final String usuarioId; // If needed directly, or get from AuthBloc

  const SubmitResenaWidget({
    super.key,
    required this.reservaId,
    required this.alojamientoId,
    // required this.usuarioId,
  });

  @override
  State<SubmitResenaWidget> createState() => _SubmitResenaWidgetState();
}

class _SubmitResenaWidgetState extends State<SubmitResenaWidget> {
  double _calificacion = 3.0; // Default rating
  final _comentarioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // final String currentUserId = context.read<AuthBloc>().state.user.id; // Example
    final String currentUserId = 'mock_user_id_for_resena';

    // BlocProvider.of<ResenaBloc>(context).add(SubmitResena(
    //   reservaId: widget.reservaId,
    //   alojamientoId: widget.alojamientoId,
    //   usuarioId: currentUserId,
    //   calificacion: _calificacion,
    //   comentario: _comentarioController.text,
    // ));
    print('Submit Reseña: ReservaID: ${widget.reservaId}, AlojID: ${widget.alojamientoId}, UserID: $currentUserId, Rating: $_calificacion, Comment: ${_comentarioController.text}');

    // Navigator.of(context).pop(); // Close dialog after submission attempt
    // Show feedback based on ResenaBloc state change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reseña enviada (placeholder).')),
    );
     Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escribe tu Reseña'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Calificación: $_calificacion estrellas', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _calificacion,
                min: 1,
                max: 5,
                divisions: 4,
                label: _calificacion.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _calificacion = value;
                  });
                },
              ),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  labelText: 'Comentario (Opcional)',
                  hintText: 'Describe tu experiencia...',
                ),
                maxLines: 3,
                // validator: (value) { // Example: make comment mandatory if rating is low
                //   if (_calificacion <= 2 && (value == null || value.isEmpty)) {
                //     return 'Por favor, explica tu calificación.';
                //   }
                //   return null;
                // }
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _submit, child: const Text('Enviar Reseña')),
      ],
    );
  }
}
