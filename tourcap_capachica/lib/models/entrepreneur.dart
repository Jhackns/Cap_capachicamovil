class Entrepreneur {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String location;
  final String contactInfo; // Ahora es obligatorio (telefono)
  final String tipoServicio; // Ahora es obligatorio
  final String email; // Campo obligatorio
  final String horarioAtencion; // Campo obligatorio
  final String precioRango; // Campo obligatorio
  final String categoria; // Campo obligatorio
  final bool estado; // Campo obligatorio

  Entrepreneur({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.location,
    required this.contactInfo,
    required this.tipoServicio,
    required this.email,
    required this.horarioAtencion,
    required this.precioRango,
    required this.categoria,
    required this.estado,
  });

  factory Entrepreneur.fromJson(Map<String, dynamic> json) {
    return Entrepreneur(
      id: json['id'],
      name: json['nombre'],
      description: json['descripcion'],
      imageUrl: json['imagenes'] != null && json['imagenes'] != '[]' ? json['imagenes'] : null,
      location: json['ubicacion'] ?? '',
      contactInfo: json['telefono'] ?? '',
      tipoServicio: json['tipoServicio'] ?? '',
      email: json['email'] ?? 'contacto@example.com',
      horarioAtencion: json['horarioAtencion'] ?? '08:00-18:00',
      precioRango: json['precioRango'] ?? '50-100 USD',
      categoria: json['categoria'] ?? 'Turismo',
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'descripcion': description ?? '',
      'imagenes': imageUrl ?? '[]',
      'ubicacion': location,
      'telefono': contactInfo,
      'email': email,
      'tipoServicio': tipoServicio,
      'horarioAtencion': horarioAtencion,
      'precioRango': precioRango,
      'categoria': categoria,
      'estado': estado,
    };
  }

  Entrepreneur copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    String? location,
    String? contactInfo,
    String? tipoServicio,
    String? email,
    String? horarioAtencion,
    String? precioRango,
    String? categoria,
    bool? estado,
  }) {
    return Entrepreneur(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      contactInfo: contactInfo ?? this.contactInfo,
      tipoServicio: tipoServicio ?? this.tipoServicio,
      email: email ?? this.email,
      horarioAtencion: horarioAtencion ?? this.horarioAtencion,
      precioRango: precioRango ?? this.precioRango,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
    );
  }
}