import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewForm extends StatefulWidget {
  final int entrepreneurId;
  final Function(Review) onSubmit;

  const ReviewForm({
    Key? key,
    required this.entrepreneurId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _comentarioController = TextEditingController();
  int _puntuacion = 5;

  @override
  void dispose() {
    _nombreController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final review = Review(
        id: 0, // El ID será asignado por el backend
        nombreAutor: _nombreController.text,
        comentario: _comentarioController.text,
        puntuacion: _puntuacion,
        emprendedorId: widget.entrepreneurId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSubmit(review);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Añadir Reseña',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Tu nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _comentarioController,
                decoration: const InputDecoration(
                  labelText: 'Tu comentario',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu comentario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Puntuación: '),
                  const SizedBox(width: 8),
                  ...List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _puntuacion ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _puntuacion = index + 1;
                        });
                      },
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enviar Reseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 