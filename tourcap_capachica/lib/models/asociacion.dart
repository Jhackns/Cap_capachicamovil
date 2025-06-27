class Asociacion {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? email;
  final int municipalidadId;
  final bool estado;
  final String? imagen;
  final String? imagenUrl;
  final double? latitud;
  final double? longitud;
  final Map<String, dynamic>? municipalidad;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Asociacion({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.email,
    required this.municipalidadId,
    required this.estado,
    this.imagen,
    this.imagenUrl,
    this.latitud,
    this.longitud,
    this.municipalidad,
    this.createdAt,
    this.updatedAt,
  });

  factory Asociacion.fromJson(Map<String, dynamic> json) {
    return Asociacion(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      telefono: json['telefono'],
      email: json['email'],
      municipalidadId: json['municipalidad_id'],
      estado: json['estado'] == 1 || json['estado'] == true,
      imagen: json['imagen'],
      imagenUrl: json['imagen_url'],
      latitud: json['latitud'] != null ? double.tryParse(json['latitud'].toString()) : null,
      longitud: json['longitud'] != null ? double.tryParse(json['longitud'].toString()) : null,
      municipalidad: json['municipalidad'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'telefono': telefono,
      'email': email,
      'municipalidad_id': municipalidadId,
      'estado': estado,
      'imagen': imagen,
      'imagen_url': imagenUrl,
      'latitud': latitud,
      'longitud': longitud,
      'municipalidad': municipalidad,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get nombreMunicipalidad {
    return municipalidad?['nombre'] ?? 'Sin municipalidad';
  }

  String get estadoText {
    return estado ? 'Activa' : 'Inactiva';
  }

  String get descripcionCorta {
    if (descripcion == null || descripcion!.isEmpty) {
      return 'Sin descripción';
    }
    if (descripcion!.length <= 100) {
      return descripcion!;
    }
    return '${descripcion!.substring(0, 100)}...';
  }
} 