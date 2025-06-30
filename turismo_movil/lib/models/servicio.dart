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
      precio: _parseDouble(json['precio_referencial']),
      emprendedor: emprendedorData?['nombre'] ?? json['emprendedor_nombre'] ?? '',
      emprendedorId: emprendedorData?['id'] ?? json['emprendedor_id'],
      categorias: (json['categorias'] as List?)?.map((c) => c['nombre']?.toString() ?? '').where((e) => e.isNotEmpty).toList() ?? [],
      categoriaIds: (json['categorias'] as List?)?.map((c) => c['id'] as int).toList() ?? [],
      estado: json['estado'] == true || json['estado'] == 1,
      capacidad: json['capacidad'] ?? 1,
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
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

  // Métodos para manejar horarios
  List<Map<String, dynamic>> getHorariosPorDia(String diaSemana) {
    return horarios.where((horario) => 
      horario['dia_semana']?.toString().toLowerCase() == diaSemana.toLowerCase()
    ).toList();
  }

  bool tieneHorarioParaDia(String diaSemana) {
    return getHorariosPorDia(diaSemana).isNotEmpty;
  }

  String getHorariosTextoPorDia(String diaSemana) {
    final horariosDia = getHorariosPorDia(diaSemana);
    if (horariosDia.isEmpty) return 'No disponible';
    
    return horariosDia.map((h) {
      final inicio = h['hora_inicio']?.toString().substring(0, 5) ?? '';
      final fin = h['hora_fin']?.toString().substring(0, 5) ?? '';
      return '$inicio - $fin';
    }).join(', ');
  }

  bool estaDisponibleEnFecha(DateTime fecha, String horaInicio, String horaFin) {
    // Obtener el día de la semana en español
    final diasSemana = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];
    final diaSemana = diasSemana[fecha.weekday % 7];
    
    // Verificar si hay horarios para ese día
    final horariosDia = getHorariosPorDia(diaSemana);
    if (horariosDia.isEmpty) return false;
    
    // Verificar si el horario solicitado está dentro de algún horario disponible
    for (final horario in horariosDia) {
      final horarioInicio = horario['hora_inicio']?.toString() ?? '';
      final horarioFin = horario['hora_fin']?.toString() ?? '';
      
      // Verificar si el horario solicitado está dentro del horario disponible
      // Convertir a minutos para comparación
      if (_compararHoras(horaInicio, horarioInicio) >= 0 && 
          _compararHoras(horaFin, horarioFin) <= 0) {
        return true;
      }
    }
    
    return false;
  }

  // Método auxiliar para comparar horas en formato HH:MM:SS
  int _compararHoras(String hora1, String hora2) {
    try {
      final partes1 = hora1.split(':');
      final partes2 = hora2.split(':');
      
      final minutos1 = int.parse(partes1[0]) * 60 + int.parse(partes1[1]);
      final minutos2 = int.parse(partes2[0]) * 60 + int.parse(partes2[1]);
      
      return minutos1.compareTo(minutos2);
    } catch (e) {
      print('Error comparando horas: $hora1 vs $hora2 - $e');
      return 0;
    }
  }

  List<String> getDiasDisponibles() {
    final diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    return diasSemana.where((dia) => tieneHorarioParaDia(dia)).toList();
  }

  Map<String, String> getHorariosCompletos() {
    final diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    final Map<String, String> horariosCompletos = {};
    
    for (final dia in diasSemana) {
      horariosCompletos[dia] = getHorariosTextoPorDia(dia);
    }
    
    return horariosCompletos;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
} 