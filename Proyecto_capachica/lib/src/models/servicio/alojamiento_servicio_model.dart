import 'package:equatable/equatable.dart';

class AlojamientoServicio extends Equatable {
  final String id; // ID of this specific link instance
  final String alojamientoId;
  final String servicioId;
  final String? detallesAdicionales; // e.g., "Wifi de alta velocidad", "Desayuno continental de 7-9am"
  final double? costoExtra; // If this specific service has an extra cost for this alojamiento

  const AlojamientoServicio({
    required this.id,
    required this.alojamientoId,
    required this.servicioId,
    this.detallesAdicionales,
    this.costoExtra,
  });

  @override
  List<Object?> get props => [id, alojamientoId, servicioId, detallesAdicionales, costoExtra];
}
