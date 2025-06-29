class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String emprendedor;
  final int? emprendedorId;
  final List<String> categorias;
  final List<int> categoriaIds;
  final bool estado;
  final int capacidad;
  final double? latitud;
  final double? longitud;
  final String? ubicacionReferencia;
  final List<Map<String, dynamic>> horarios;
  final List<Map<String, dynamic>> sliders;
  
  // Información completa del emprendedor
  final String? emprendedorTelefono;
  final String? emprendedorEmail;
  final String? emprendedorUbicacion;
  final String? emprendedorDescripcion;
  final String? emprendedorTipoServicio;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.emprendedor,
    this.emprendedorId,
    required this.categorias,
    required this.categoriaIds,
    required this.estado,
    required this.capacidad,
    this.latitud,
    this.longitud,
    this.ubicacionReferencia,
    required this.horarios,
    required this.sliders,
    this.emprendedorTelefono,
    this.emprendedorEmail,
    this.emprendedorUbicacion,
    this.emprendedorDescripcion,
    this.emprendedorTipoServicio,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    // Extraer información del emprendedor
    final emprendedorData = json['emprendedor'];
    String? telefono;
    String? email;
    String? ubicacion;
    String? descripcion;
    String? tipoServicio;
    
    if (emprendedorData is Map<String, dynamic>) {
      telefono = emprendedorData['telefono'];
      email = emprendedorData['email'];
      ubicacion = emprendedorData['ubicacion'];
      descripcion = emprendedorData['descripcion'];
      tipoServicio = emprendedorData['tipo_servicio'];
    }
    
    return Servicio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio_referencial'] is String)
          ? double.tryParse(json['precio_referencial']) ?? 0.0
          : (json['precio_referencial'] ?? 0.0).toDouble(),
      emprendedor: emprendedorData?['nombre'] ?? json['emprendedor_nombre'] ?? '',
      emprendedorId: emprendedorData?['id'] ?? json['emprendedor_id'],
      categorias: (json['categorias'] as List?)?.map((c) => c['nombre']?.toString() ?? '').where((e) => e.isNotEmpty).toList() ?? [],
      categoriaIds: (json['categorias'] as List?)?.map((c) => c['id'] as int).toList() ?? [],
      estado: json['estado'] == true || json['estado'] == 1,
      capacidad: json['capacidad'] ?? 1,
      latitud: (json['latitud'] is String)
          ? double.tryParse(json['latitud'])
          : (json['latitud'] != null) ? json['latitud'].toDouble() : null,
      longitud: (json['longitud'] is String)
          ? double.tryParse(json['longitud'])
          : (json['longitud'] != null) ? json['longitud'].toDouble() : null,
      ubicacionReferencia: json['ubicacion_referencia'],
      horarios: (json['horarios'] as List?)?.map((h) => Map<String, dynamic>.from(h)).toList() ?? [],
      sliders: (json['sliders'] as List?)?.map((s) => Map<String, dynamic>.from(s)).toList() ?? [],
      emprendedorTelefono: telefono,
      emprendedorEmail: email,
      emprendedorUbicacion: ubicacion,
      emprendedorDescripcion: descripcion,
      emprendedorTipoServicio: tipoServicio,
    );
  }

  String get estadoText => estado ? 'Activo' : 'Inactivo';
  String get categoriasText => categorias.join(', ');
  String get horariosText => '${horarios.length} horarios';
  String get ubicacionText => ubicacionReferencia ?? 'No especificada';
  String get coordenadasText => (latitud != null && longitud != null) 
      ? '${latitud!.toStringAsFixed(6)}, ${longitud!.toStringAsFixed(6)}' 
      : 'No especificadas';
      
  // Getters para información del emprendedor
  String get emprendedorTelefonoText => emprendedorTelefono ?? 'No especificado';
  String get emprendedorEmailText => emprendedorEmail ?? 'No especificado';
  String get emprendedorUbicacionText => emprendedorUbicacion ?? 'No especificada';
  String get emprendedorDescripcionText => emprendedorDescripcion ?? 'Sin descripción';
  String get emprendedorTipoServicioText => emprendedorTipoServicio ?? 'No especificado';
} 