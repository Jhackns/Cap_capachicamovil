import 'package:equatable/equatable.dart';

class FotoAlojamiento extends Equatable {
  final String id;
  final String alojamientoId; // Foreign key to Alojamiento
  final String urlFoto;
  final String? descripcion; // Optional caption for the photo

  const FotoAlojamiento({
    required this.id,
    required this.alojamientoId,
    required this.urlFoto,
    this.descripcion,
  });

  @override
  List<Object?> get props => [id, alojamientoId, urlFoto, descripcion];
}
