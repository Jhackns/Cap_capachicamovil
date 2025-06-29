import 'package:flutter/material.dart';

class ReservaServicioForm {
  int? servicioId;
  int? emprendedorId;
  String? emprendedorNombre;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  TimeOfDay? horaInicio;
  TimeOfDay? horaFin;
  int duracionMinutos;
  int cantidad;
  double precio;
  String estado;
  String? notasCliente;
  String? notasEmprendedor;

  ReservaServicioForm({
    this.servicioId,
    this.emprendedorId,
    this.emprendedorNombre,
    this.fechaInicio,
    this.fechaFin,
    this.horaInicio,
    this.horaFin,
    this.duracionMinutos = 0,
    this.cantidad = 1,
    this.precio = 0.0,
    this.estado = 'pendiente',
    this.notasCliente,
    this.notasEmprendedor,
  });

  ReservaServicioForm copyWith({
    int? servicioId,
    int? emprendedorId,
    String? emprendedorNombre,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    TimeOfDay? horaInicio,
    TimeOfDay? horaFin,
    int? duracionMinutos,
    int? cantidad,
    double? precio,
    String? estado,
    String? notasCliente,
    String? notasEmprendedor,
  }) {
    return ReservaServicioForm(
      servicioId: servicioId ?? this.servicioId,
      emprendedorId: emprendedorId ?? this.emprendedorId,
      emprendedorNombre: emprendedorNombre ?? this.emprendedorNombre,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      notasCliente: notasCliente ?? this.notasCliente,
      notasEmprendedor: notasEmprendedor ?? this.notasEmprendedor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'servicio_id': servicioId,
      'emprendedor_id': emprendedorId,
      'fecha_inicio': fechaInicio?.toIso8601String().split('T')[0],
      'fecha_fin': fechaFin?.toIso8601String().split('T')[0],
      'hora_inicio': horaInicio != null 
          ? '${horaInicio!.hour.toString().padLeft(2, '0')}:${horaInicio!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'hora_fin': horaFin != null 
          ? '${horaFin!.hour.toString().padLeft(2, '0')}:${horaFin!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'duracion_minutos': duracionMinutos,
      'cantidad': cantidad,
      'precio': precio,
      'estado': estado,
      'notas_cliente': notasCliente,
      'notas_emprendedor': notasEmprendedor,
    };
  }

  factory ReservaServicioForm.fromJson(Map<String, dynamic> json) {
    DateTime? parseFecha(String? fecha) {
      if (fecha == null) return null;
      try {
        return DateTime.parse(fecha);
      } catch (_) {
        return null;
      }
    }

    TimeOfDay? parseHora(String? hora) {
      if (hora == null) return null;
      try {
        final parts = hora.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      } catch (_) {
        return null;
      }
    }

    double parsePrecio(dynamic precio) {
      if (precio == null) return 0.0;
      if (precio is double) return precio;
      if (precio is int) return precio.toDouble();
      if (precio is String) {
        try {
          // Limpiar el string de caracteres no numéricos excepto punto y coma
          final cleanString = precio.replaceAll(RegExp(r'[^\d.,]'), '');
          // Reemplazar coma por punto si es necesario
          final normalizedString = cleanString.replaceAll(',', '.');
          return double.parse(normalizedString);
        } catch (e) {
          print('Error parsing precio: $precio - $e');
          return 0.0;
        }
      }
      return 0.0;
    }

    return ReservaServicioForm(
      servicioId: json['servicio_id'],
      emprendedorId: json['emprendedor_id'],
      emprendedorNombre: json['emprendedor_nombre'],
      fechaInicio: parseFecha(json['fecha_inicio']),
      fechaFin: parseFecha(json['fecha_fin']),
      horaInicio: parseHora(json['hora_inicio']),
      horaFin: parseHora(json['hora_fin']),
      duracionMinutos: json['duracion_minutos'] ?? 0,
      cantidad: json['cantidad'] ?? 1,
      precio: parsePrecio(json['precio']),
      estado: json['estado'] ?? 'pendiente',
      notasCliente: json['notas_cliente'],
      notasEmprendedor: json['notas_emprendedor'],
    );
  }

  void calcularDuracion() {
    if (horaInicio != null && horaFin != null) {
      final inicio = horaInicio!;
      final fin = horaFin!;
      
      int minutosInicio = inicio.hour * 60 + inicio.minute;
      int minutosFin = fin.hour * 60 + fin.minute;
      
      if (minutosFin > minutosInicio) {
        duracionMinutos = minutosFin - minutosInicio;
      } else {
        duracionMinutos = 0;
      }
    }
  }

  bool get isValid {
    return servicioId != null && 
           fechaInicio != null && 
           horaInicio != null && 
           horaFin != null &&
           precio > 0;
  }
} 