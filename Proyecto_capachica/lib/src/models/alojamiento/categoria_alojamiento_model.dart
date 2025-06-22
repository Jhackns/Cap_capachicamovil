import 'package:equatable/equatable.dart';

class CategoriaAlojamiento extends Equatable {
  final String id;
  final String nombre;
  // final String? descripcion; // Optional

  const CategoriaAlojamiento({
    required this.id,
    required this.nombre,
    // this.descripcion,
  });

  @override
  List<Object?> get props => [id, nombre];
}
