class CarritoItem {
  final int id;
  final int servicioId;
  final String nombreServicio;
  final String nombreEmprendedor;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final double precio;
  final int cantidad;

  CarritoItem({
    required this.id,
    required this.servicioId,
    required this.nombreServicio,
    required this.nombreEmprendedor,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.precio,
    this.cantidad = 1,
  });

  // Método para obtener el precio total del item
  double get precioTotal => precio * cantidad;

  // Método para obtener la fecha formateada
  String get fechaFormateada {
    return '${fecha.day}/${fecha.month}';
  }

  // Método para obtener el horario formateado
  String get horarioFormateado {
    return '$horaInicio - $horaFin';
  }

  // Método para obtener solo la hora de inicio formateada
  String get horaInicioFormateada {
    final partes = horaInicio.split(':');
    return '${partes[0]}:${partes[1]}';
  }

  // Método para obtener solo la hora de fin formateada
  String get horaFinFormateada {
    final partes = horaFin.split(':');
    return '${partes[0]}:${partes[1]}';
  }

  // Método para obtener el horario completo formateado
  String get horarioCompleto {
    return '${horaInicio.substring(0, 5)} - ${horaFin.substring(0, 5)}';
  }

  // Método copyWith para crear una copia modificada
  CarritoItem copyWith({
    int? id,
    int? servicioId,
    String? nombreServicio,
    String? nombreEmprendedor,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    double? precio,
    int? cantidad,
  }) {
    return CarritoItem(
      id: id ?? this.id,
      servicioId: servicioId ?? this.servicioId,
      nombreServicio: nombreServicio ?? this.nombreServicio,
      nombreEmprendedor: nombreEmprendedor ?? this.nombreEmprendedor,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  // Método para convertir a Map (útil para persistencia)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servicioId': servicioId,
      'nombreServicio': nombreServicio,
      'nombreEmprendedor': nombreEmprendedor,
      'fecha': fecha.toIso8601String(),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'servicio_id': servicioId,
      'nombre_servicio': nombreServicio,
      'nombre_emprendedor': nombreEmprendedor,
      'fecha': fecha.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  // Método para crear desde Map
  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      id: map['id'],
      servicioId: map['servicioId'],
      nombreServicio: map['nombreServicio'],
      nombreEmprendedor: map['nombreEmprendedor'],
      fecha: DateTime.parse(map['fecha']),
      horaInicio: map['horaInicio'],
      horaFin: map['horaFin'],
      precio: _parseDouble(map['precio']),
      cantidad: map['cantidad'],
    );
  }

  // Método para crear desde JSON
  factory CarritoItem.fromJson(Map<String, dynamic> json) {
    return CarritoItem(
      id: json['id'],
      servicioId: json['servicio_id'],
      nombreServicio: json['nombre_servicio'] ?? json['servicio']['nombre'] ?? '',
      nombreEmprendedor: json['nombre_emprendedor'] ?? json['emprendedor']['nombre'] ?? '',
      fecha: DateTime.parse(json['fecha_inicio']),
      horaInicio: json['hora_inicio'],
      horaFin: json['hora_fin'],
      precio: _parseDouble(json['precio']),
      cantidad: json['cantidad'] ?? 1,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarritoItem &&
        other.servicioId == servicioId &&
        other.fecha == fecha &&
        other.horaInicio == horaInicio &&
        other.horaFin == horaFin;
  }

  @override
  int get hashCode {
    return servicioId.hashCode ^
        fecha.hashCode ^
        horaInicio.hashCode ^
        horaFin.hashCode;
  }
} 