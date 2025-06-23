import 'dart:convert';

class Entrepreneur {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String location;
  final String contactInfo;
  final String tipoServicio;
  final String email;
  final String? paginaWeb;
  final String horarioAtencion;
  final String precioRango;
  final List<String> metodosPago;
  final String? capacidadAforo;
  final String? numeroPersonasAtiende;
  final String? comentariosResenas;
  final List<String> imagenes;
  final String categoria;
  final List<String> certificaciones;
  final List<String> idiomasHablados;
  final List<String> opcionesAcceso;
  final bool facilidadesDiscapacidad;
  final int? asociacionId;
  final bool estado;

  Entrepreneur({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.location,
    required this.contactInfo,
    required this.tipoServicio,
    required this.email,
    this.paginaWeb,
    required this.horarioAtencion,
    required this.precioRango,
    required this.metodosPago,
    this.capacidadAforo,
    this.numeroPersonasAtiende,
    this.comentariosResenas,
    required this.imagenes,
    required this.categoria,
    required this.certificaciones,
    required this.idiomasHablados,
    required this.opcionesAcceso,
    required this.facilidadesDiscapacidad,
    this.asociacionId,
    required this.estado,
  });

  factory Entrepreneur.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String && value.isNotEmpty && value != '[]') {
        try {
          final decoded = value.startsWith('[') ? List.from(jsonDecode(value)) : value.split(',');
          return decoded.map((e) => e.toString().trim()).toList();
        } catch (_) {
          return value.split(',').map((e) => e.trim()).toList();
        }
      }
      return [];
    }
    return Entrepreneur(
      id: json['id'],
      name: json['nombre'] ?? '',
      description: json['descripcion'],
      imageUrl: (json['imagenes'] is String && json['imagenes'].isNotEmpty) ? json['imagenes'] : null,
      location: json['ubicacion'] ?? '',
      contactInfo: json['telefono'] ?? '',
      tipoServicio: json['tipo_servicio'] ?? '',
      email: json['email'] ?? '',
      paginaWeb: json['pagina_web'],
      horarioAtencion: json['horario_atencion'] ?? '',
      precioRango: json['precio_rango'] ?? '',
      metodosPago: parseList(json['metodos_pago']),
      capacidadAforo: json['capacidad_aforo']?.toString(),
      numeroPersonasAtiende: json['numero_personas_atiende']?.toString(),
      comentariosResenas: json['comentarios_resenas'],
      imagenes: parseList(json['imagenes']),
      categoria: json['categoria'] ?? '',
      certificaciones: parseList(json['certificaciones']),
      idiomasHablados: parseList(json['idiomas_hablados']),
      opcionesAcceso: parseList(json['opciones_acceso']),
      facilidadesDiscapacidad: json['facilidades_discapacidad'] == true || json['facilidades_discapacidad'] == 1,
      asociacionId: json['asociacion_id'] != null ? int.tryParse(json['asociacion_id'].toString()) : null,
      estado: json['estado'] == true || json['estado'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name,
      'descripcion': description ?? '',
      'imagenes': imagenes,
      'ubicacion': location,
      'telefono': contactInfo,
      'tipo_servicio': tipoServicio,
      'email': email,
      'pagina_web': paginaWeb,
      'horario_atencion': horarioAtencion,
      'precio_rango': precioRango,
      'metodos_pago': metodosPago,
      'capacidad_aforo': capacidadAforo,
      'numero_personas_atiende': numeroPersonasAtiende,
      'comentarios_resenas': comentariosResenas,
      'categoria': categoria,
      'certificaciones': certificaciones,
      'idiomas_hablados': idiomasHablados,
      'opciones_acceso': opcionesAcceso,
      'facilidades_discapacidad': facilidadesDiscapacidad,
      'asociacion_id': asociacionId,
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
    String? paginaWeb,
    String? horarioAtencion,
    String? precioRango,
    List<String>? metodosPago,
    String? capacidadAforo,
    String? numeroPersonasAtiende,
    String? comentariosResenas,
    List<String>? imagenes,
    String? categoria,
    List<String>? certificaciones,
    List<String>? idiomasHablados,
    List<String>? opcionesAcceso,
    bool? facilidadesDiscapacidad,
    int? asociacionId,
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
      paginaWeb: paginaWeb ?? this.paginaWeb,
      horarioAtencion: horarioAtencion ?? this.horarioAtencion,
      precioRango: precioRango ?? this.precioRango,
      metodosPago: metodosPago ?? this.metodosPago,
      capacidadAforo: capacidadAforo ?? this.capacidadAforo,
      numeroPersonasAtiende: numeroPersonasAtiende ?? this.numeroPersonasAtiende,
      comentariosResenas: comentariosResenas ?? this.comentariosResenas,
      imagenes: imagenes ?? this.imagenes,
      categoria: categoria ?? this.categoria,
      certificaciones: certificaciones ?? this.certificaciones,
      idiomasHablados: idiomasHablados ?? this.idiomasHablados,
      opcionesAcceso: opcionesAcceso ?? this.opcionesAcceso,
      facilidadesDiscapacidad: facilidadesDiscapacidad ?? this.facilidadesDiscapacidad,
      asociacionId: asociacionId ?? this.asociacionId,
      estado: estado ?? this.estado,
    );
  }
}