class Municipalidad {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? redFacebook;
  final String? redInstagram;
  final String? redYoutube;
  final String? coordenadasX;
  final String? coordenadasY;
  final String? frase;
  final String? comunidades;
  final String? historiafamilias;
  final String? historiacapachica;
  final String? comite;
  final String? mision;
  final String? vision;
  final String? valores;
  final String? ordenanzamunicipal;
  final String? alianzas;
  final String? correo;
  final String? horariodeatencion;
  final String? createdAt;
  final String? updatedAt;

  Municipalidad({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.redFacebook,
    this.redInstagram,
    this.redYoutube,
    this.coordenadasX,
    this.coordenadasY,
    this.frase,
    this.comunidades,
    this.historiafamilias,
    this.historiacapachica,
    this.comite,
    this.mision,
    this.vision,
    this.valores,
    this.ordenanzamunicipal,
    this.alianzas,
    this.correo,
    this.horariodeatencion,
    this.createdAt,
    this.updatedAt,
  });

  factory Municipalidad.fromJson(Map<String, dynamic> json) {
    return Municipalidad(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      redFacebook: json['red_facebook'],
      redInstagram: json['red_instagram'],
      redYoutube: json['red_youtube'],
      coordenadasX: json['coordenadas_x']?.toString(),
      coordenadasY: json['coordenadas_y']?.toString(),
      frase: json['frase'],
      comunidades: json['comunidades'],
      historiafamilias: json['historiafamilias'],
      historiacapachica: json['historiacapachica'],
      comite: json['comite'],
      mision: json['mision'],
      vision: json['vision'],
      valores: json['valores'],
      ordenanzamunicipal: json['ordenanzamunicipal'],
      alianzas: json['alianzas'],
      correo: json['correo'],
      horariodeatencion: json['horariodeatencion'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nombre': nombre,
      'descripcion': descripcion,
      'red_facebook': redFacebook,
      'red_instagram': redInstagram,
      'red_youtube': redYoutube,
      'coordenadas_x': coordenadasX,
      'coordenadas_y': coordenadasY,
      'frase': frase,
      'comunidades': comunidades,
      'historiafamilias': historiafamilias,
      'historiacapachica': historiacapachica,
      'comite': comite,
      'mision': mision,
      'vision': vision,
      'valores': valores,
      'ordenanzamunicipal': ordenanzamunicipal,
      'alianzas': alianzas,
      'correo': correo,
      'horariodeatencion': horariodeatencion,
    };
    // No incluir el id en el JSON para la creación
    return data;
  }
} 