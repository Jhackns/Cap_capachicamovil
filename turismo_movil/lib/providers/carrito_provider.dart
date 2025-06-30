import 'package:flutter/foundation.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';

class CarritoProvider with ChangeNotifier {
  final List<CarritoItem> _items = [];
  final CarritoService _carritoService = CarritoService();
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getter para obtener todos los items
  List<CarritoItem> get items => List.unmodifiable(_items);

  // Getter para obtener la cantidad total de items
  int get cantidadItems => _items.length;

  // Getter para obtener el precio total
  double get precioTotal {
    return _items.fold(0.0, (total, item) => total + item.precioTotal);
  }

  // Getter para verificar si el carrito está vacío
  bool get estaVacio => _items.isEmpty;

  // Getter para verificar si está cargando
  bool get isLoading => _isLoading;

  // Inicializar carrito desde el backend
  Future<void> inicializarCarrito() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final itemsBackend = await _carritoService.sincronizarCarrito();
      _items.clear();
      _items.addAll(itemsBackend);
      _isInitialized = true;
    } catch (e) {
      print('❌ Error inicializando carrito: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para agregar un item al carrito
  Future<bool> agregarItem({
    required int servicioId,
    required String nombreServicio,
    required String nombreEmprendedor,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
    required double precio,
    int cantidad = 1,
    int? emprendedorId,
  }) async {
    try {
      print('🛒 CarritoProvider.agregarItem iniciado');
      print('📋 Parámetros: servicioId=$servicioId, emprendedorId=$emprendedorId, fecha=$fecha');
      
      // Probar autenticación primero
      print('🔍 Probando autenticación antes de agregar...');
      final authOk = await _carritoService.probarAutenticacion();
      if (!authOk) {
        print('❌ Autenticación falló, no se puede agregar al carrito');
        return false;
      }
      print('✅ Autenticación exitosa, procediendo a agregar...');
      
      // Verificar si ya existe un item con el mismo servicio, fecha y horario
      final itemExistente = _items.where((item) =>
          item.servicioId == servicioId &&
          item.fecha == fecha &&
          item.horaInicio == horaInicio &&
          item.horaFin == horaFin).firstOrNull;

      if (itemExistente != null) {
        print('⚠️ Item ya existe en carrito local, actualizando cantidad');
        // Si existe, actualizar la cantidad
        final index = _items.indexOf(itemExistente);
        _items[index] = itemExistente.copyWith(
          cantidad: itemExistente.cantidad + cantidad,
        );
        notifyListeners();
        return true;
      }

      print('🔄 Item no existe, agregando nuevo item');

      // Calcular duración en minutos
      final duracionMinutos = _calcularDuracionMinutos(horaInicio, horaFin);
      print('⏱️ Duración calculada: $duracionMinutos minutos');

      // Agregar al backend
      print('📡 Llamando a _carritoService.agregarAlCarrito...');
      final success = await _carritoService.agregarAlCarrito(
        servicioId: servicioId,
        emprendedorId: emprendedorId ?? 1, // Valor por defecto si no se proporciona
        fechaInicio: fecha,
        fechaFin: fecha,
        horaInicio: horaInicio,
        horaFin: horaFin,
        duracionMinutos: duracionMinutos,
        cantidad: cantidad,
      );

      print('📡 Resultado de agregarAlCarrito: $success');

      if (success) {
        print('✅ Éxito al agregar al backend, sincronizando carrito...');
        // Sincronizar con el backend para obtener el ID real
        await sincronizarCarrito();
        print('✅ Sincronización completada');
        return true;
      } else {
        print('❌ Fallo al agregar al backend');
        return false;
      }
    } catch (e) {
      print('❌ Error en CarritoProvider.agregarItem: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Método para eliminar un item específico
  Future<bool> eliminarItem(int id) async {
    try {
      final success = await _carritoService.eliminarDelCarrito(id);
      if (success) {
        await sincronizarCarrito();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error eliminando item: $e');
      return false;
    }
  }

  // Método para actualizar la cantidad de un item
  Future<bool> actualizarCantidad(int id, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      return await eliminarItem(id);
    }

    try {
      // Para actualizar cantidad, eliminamos y volvemos a agregar
      final item = _items.firstWhere((item) => item.id == id);
      final eliminado = await eliminarItem(id);
      if (eliminado) {
        return await agregarItem(
          servicioId: item.servicioId,
          nombreServicio: item.nombreServicio,
          nombreEmprendedor: item.nombreEmprendedor,
          fecha: item.fecha,
          horaInicio: item.horaInicio,
          horaFin: item.horaFin,
          precio: item.precio,
          cantidad: nuevaCantidad,
        );
      }
      return false;
    } catch (e) {
      print('❌ Error actualizando cantidad: $e');
      return false;
    }
  }

  // Método para vaciar el carrito
  Future<bool> vaciarCarrito() async {
    try {
      final success = await _carritoService.vaciarCarrito();
      if (success) {
        _items.clear();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error vaciando carrito: $e');
      return false;
    }
  }

  // Método para confirmar el carrito
  Future<Map<String, dynamic>?> confirmarCarrito({String? notas}) async {
    try {
      final reserva = await _carritoService.confirmarCarrito(notas: notas);
      if (reserva != null) {
        // Limpiar carrito local después de confirmar
        _items.clear();
        notifyListeners();
        return reserva;
      }
      return null;
    } catch (e) {
      print('❌ Error confirmando carrito: $e');
      return null;
    }
  }

  // Método para verificar si un servicio ya está en el carrito
  bool servicioEnCarrito({
    required int servicioId,
    required DateTime fecha,
    required String horaInicio,
    required String horaFin,
  }) {
    return _items.any((item) =>
        item.servicioId == servicioId &&
        item.fecha == fecha &&
        item.horaInicio == horaInicio &&
        item.horaFin == horaFin);
  }

  // Método para obtener un item específico
  CarritoItem? obtenerItem(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Método para obtener items por servicio
  List<CarritoItem> obtenerItemsPorServicio(int servicioId) {
    return _items.where((item) => item.servicioId == servicioId).toList();
  }

  // Método para obtener items por fecha
  List<CarritoItem> obtenerItemsPorFecha(DateTime fecha) {
    return _items.where((item) => 
        item.fecha.year == fecha.year &&
        item.fecha.month == fecha.month &&
        item.fecha.day == fecha.day).toList();
  }

  // Método para obtener el total de items por servicio
  int obtenerCantidadPorServicio(int servicioId) {
    return _items
        .where((item) => item.servicioId == servicioId)
        .fold(0, (total, item) => total + item.cantidad);
  }

  // Método para obtener el precio total por servicio
  double obtenerPrecioTotalPorServicio(int servicioId) {
    return _items
        .where((item) => item.servicioId == servicioId)
        .fold(0.0, (total, item) => total + item.precioTotal);
  }

  // Método para obtener estadísticas del carrito
  Map<String, dynamic> obtenerEstadisticas() {
    final serviciosUnicos = _items.map((item) => item.servicioId).toSet().length;
    final fechasUnicas = _items.map((item) => 
        '${item.fecha.year}-${item.fecha.month}-${item.fecha.day}').toSet().length;
    
    return {
      'totalItems': cantidadItems,
      'serviciosUnicos': serviciosUnicos,
      'fechasUnicas': fechasUnicas,
      'precioTotal': precioTotal,
    };
  }

  // Método para sincronizar con el backend
  Future<void> sincronizarCarrito() async {
    try {
      print('🔄 Iniciando sincronización del carrito...');
      final itemsBackend = await _carritoService.sincronizarCarrito();
      print('📦 Items obtenidos del backend: ${itemsBackend.length}');
      
      _items.clear();
      _items.addAll(itemsBackend);
      print('✅ Carrito local actualizado con ${_items.length} items');
      notifyListeners();
    } catch (e) {
      print('❌ Error sincronizando carrito: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  // Método auxiliar para calcular duración en minutos
  int _calcularDuracionMinutos(String horaInicio, String horaFin) {
    try {
      final partesInicio = horaInicio.split(':');
      final partesFin = horaFin.split(':');
      
      final minutosInicio = int.parse(partesInicio[0]) * 60 + int.parse(partesInicio[1]);
      final minutosFin = int.parse(partesFin[0]) * 60 + int.parse(partesFin[1]);
      
      return minutosFin - minutosInicio;
    } catch (e) {
      return 60; // Valor por defecto
    }
  }

  // Método para refrescar el carrito
  Future<void> refrescarCarrito() async {
    await sincronizarCarrito();
  }
} 