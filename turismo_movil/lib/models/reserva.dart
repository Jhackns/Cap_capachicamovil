import 'reserva_servicio.dart';

class Reserva {
  final int id;
  final String? codigo;
  final DateTime fechaCreacion;
  final String estado;
  final String? notas;
  final double? precioTotal;
  final List<ReservaServicio>? servicios;
  final int? usuarioId;

  Reserva({
    required this.id,
    this.codigo,
    required this.fechaCreacion,
    required this.estado,
    this.notas,
    this.precioTotal,
    this.servicios,
    this.usuarioId,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? 0,
      codigo: json['codigo'],
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      estado: json['estado'] ?? 'pendiente',
      notas: json['notas'],
      precioTotal: _parseDouble(json['precio_total']),
      servicios: json['servicios'] != null
          ? (json['servicios'] as List)
              .map((servicio) => ReservaServicio.fromJson(servicio))
              .toList()
          : null,
      usuarioId: json['usuario_id'],
    );
  }

  // Helper method to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'estado': estado,
      'notas': notas,
      'precio_total': precioTotal,
      'servicios': servicios?.map((s) => s.toJson()).toList(),
      'usuario_id': usuarioId,
    };
  }

  Reserva copyWith({
    int? id,
    String? codigo,
    DateTime? fechaCreacion,
    String? estado,
    String? notas,
    double? precioTotal,
    List<ReservaServicio>? servicios,
    int? usuarioId,
  }) {
    return Reserva(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      precioTotal: precioTotal ?? this.precioTotal,
      servicios: servicios ?? this.servicios,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  @override
  String toString() {
    return 'Reserva(id: $id, codigo: $codigo, estado: $estado, fechaCreacion: $fechaCreacion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reserva && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 