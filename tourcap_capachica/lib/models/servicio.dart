class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String emprendedor;
  final List<String> categorias;
  final bool estado;
  final List<Map<String, dynamic>> horarios;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.emprendedor,
    required this.categorias,
    required this.estado,
    required this.horarios,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] is String)
          ? double.tryParse(json['precio']) ?? 0.0
          : (json['precio'] ?? 0.0).toDouble(),
      emprendedor: json['emprendedor']?['nombre'] ?? json['emprendedor_nombre'] ?? '',
      categorias: (json['categorias'] as List?)?.map((c) => c['nombre']?.toString() ?? '').where((e) => e.isNotEmpty).toList() ?? [],
      estado: json['estado'] == true || json['estado'] == 1,
      horarios: (json['horarios'] as List?)?.map((h) => Map<String, dynamic>.from(h)).toList() ?? [],
    );
  }

  String get estadoText => estado ? 'Activo' : 'Inactivo';
  String get categoriasText => categorias.join(', ');
  String get horariosText => '${horarios.length} horarios';
} 