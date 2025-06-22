import 'package:equatable/equatable.dart';

class Direccion extends Equatable {
  final String id;
  final String calle;
  final String? numero;
  final String ciudad;
  final String region; // e.g., Puno
  final String pais; // e.g., Perú
  final double? latitud;
  final double? longitud;

  const Direccion({
    required this.id,
    required this.calle,
    this.numero,
    required this.ciudad,
    required this.region,
    required this.pais,
    this.latitud,
    this.longitud,
  });

  @override
  List<Object?> get props => [id, calle, numero, ciudad, region, pais, latitud, longitud];

  String get fullAddress => '$calle ${numero ?? ''}, $ciudad, $region, $pais';
}
