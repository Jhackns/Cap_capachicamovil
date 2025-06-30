class ReservaServicio {
  final int id;
  final int reservaId;
  final int servicioId;
  final int emprendedorId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String horaInicio;
  final String horaFin;
  final int duracionMinutos;
  final int cantidad;
  final double precio;
  final String estado;
  final String? notas;
  final String? nombreServicio;
  final String? nombreEmprendedor;

  ReservaServicio({
    required this.id,
    required this.reservaId,
    required this.servicioId,
    required this.emprendedorId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionMinutos,
    required this.cantidad,
    required this.precio,
    required this.estado,
    this.notas,
    this.nombreServicio,
    this.nombreEmprendedor,
  });

  factory ReservaServicio.fromJson(Map<String, dynamic> json) {
    return ReservaServicio(
      id: json['id'] ?? 0,
      reservaId: json['reserva_id'] ?? 0,
      servicioId: json['servicio_id'] ?? 0,
      emprendedorId: json['emprendedor_id'] ?? 0,
      fechaInicio: DateTime.parse(json['fecha_inicio'] ?? DateTime.now().toIso8601String()),
      fechaFin: DateTime.parse(json['fecha_fin'] ?? DateTime.now().toIso8601String()),
      horaInicio: json['hora_inicio'] ?? '00:00:00',
      horaFin: json['hora_fin'] ?? '00:00:00',
      duracionMinutos: json['duracion_minutos'] ?? 0,
      cantidad: json['cantidad'] ?? 1,
      precio: _parseDouble(json['precio']),
      estado: json['estado'] ?? 'pendiente',
      notas: json['notas'],
      nombreServicio: json['nombre_servicio'] ?? json['servicio']?['nombre'],
      nombreEmprendedor: json['nombre_emprendedor'] ?? json['emprendedor']?['nombre'],
    );
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reserva_id': reservaId,
      'servicio_id': servicioId,
      'emprendedor_id': emprendedorId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin.toIso8601String(),
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'duracion_minutos': duracionMinutos,
      'cantidad': cantidad,
      'precio': precio,
      'estado': estado,
      'notas': notas,
      'nombre_servicio': nombreServicio,
      'nombre_emprendedor': nombreEmprendedor,
    };
  }

  ReservaServicio copyWith({
    int? id,
    int? reservaId,
    int? servicioId,
    int? emprendedorId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? horaInicio,
    String? horaFin,
    int? duracionMinutos,
    int? cantidad,
    double? precio,
    String? estado,
    String? notas,
    String? nombreServicio,
    String? nombreEmprendedor,
  }) {
    return ReservaServicio(
      id: id ?? this.id,
      reservaId: reservaId ?? this.reservaId,
      servicioId: servicioId ?? this.servicioId,
      emprendedorId: emprendedorId ?? this.emprendedorId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      nombreServicio: nombreServicio ?? this.nombreServicio,
      nombreEmprendedor: nombreEmprendedor ?? this.nombreEmprendedor,
    );
  }

  @override
  String toString() {
    return 'ReservaServicio(id: $id, servicioId: $servicioId, estado: $estado, fechaInicio: $fechaInicio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservaServicio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 