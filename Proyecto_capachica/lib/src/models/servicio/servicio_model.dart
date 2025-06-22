import 'package:equatable/equatable.dart';

class Servicio extends Equatable {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? iconoUrlOrCode; // Could be a URL to an image or a font icon code like 'wifi'

  const Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.iconoUrlOrCode,
  });

  @override
  List<Object?> get props => [id, nombre, descripcion, iconoUrlOrCode];
}
