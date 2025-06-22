// Placeholder for ServicioService
import '../../models/servicio/servicio_model.dart';
import '../../models/servicio/alojamiento_servicio_model.dart';

class ServicioService {
  ServicioService();

  Future<List<Servicio>> getMasterServicios() async {
    print('ServicioService (Placeholder): Fetching all master servicios.');
    await Future.delayed(const Duration(milliseconds: 300));
    return _getMockMasterServiciosFromService();
  }

  Future<List<Servicio>> getServiciosForAlojamiento(String alojamientoId) async {
    // This should ideally return full Servicio objects, possibly with AlojamientoServicio details
    print('ServicioService (Placeholder): Fetching servicios for alojamiento ID: $alojamientoId');
    await Future.delayed(const Duration(milliseconds: 300));
    // This mock is simplified; it should cross-reference AlojamientoServicio with Servicio
    if (alojamientoId == 'alo1' || alojamientoId == 'alo1_service') {
      return [
        const Servicio(id: 'serv1', nombre: 'WiFi (Detalle Servicio)', iconoUrlOrCode: 'wifi'),
        const Servicio(id: 'serv2', nombre: 'Desayuno (Detalle Servicio)', iconoUrlOrCode: 'free_breakfast'),
      ];
    }
    return [];
  }

  Future<Servicio> createMasterServicio(String nombre, String? descripcion, String? icono) async {
    print('ServicioService (Placeholder): Creating master servicio: $nombre');
    await Future.delayed(const Duration(milliseconds: 300));
    return Servicio(id: 'mserv_${DateTime.now().millisecondsSinceEpoch}', nombre: nombre, descripcion: descripcion, iconoUrlOrCode: icono);
  }

  Future<Servicio> updateMasterServicio(String id, String nombre, String? descripcion, String? icono) async {
    print('ServicioService (Placeholder): Updating master servicio ID $id: $nombre');
    await Future.delayed(const Duration(milliseconds: 300));
    return Servicio(id: id, nombre: nombre, descripcion: descripcion, iconoUrlOrCode: icono);
  }

  Future<void> deleteMasterServicio(String id) async {
    print('ServicioService (Placeholder): Deleting master servicio ID: $id');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<AlojamientoServicio> linkServicio(String alojamientoId, String servicioId, String? detalles, double? costo) async {
    print('ServicioService (Placeholder): Linking servicio $servicioId to alojamiento $alojamientoId');
    await Future.delayed(const Duration(milliseconds: 300));
    return AlojamientoServicio(
      id: 'aslink_${DateTime.now().millisecondsSinceEpoch}',
      alojamientoId: alojamientoId,
      servicioId: servicioId,
      detallesAdicionales: detalles,
      costoExtra: costo
    );
  }

  Future<void> unlinkServicio(String alojamientoServicioId) async {
    print('ServicioService (Placeholder): Unlinking alojamientoServicio ID: $alojamientoServicioId');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Mock data helper
  List<Servicio> _getMockMasterServiciosFromService() {
    return [
      const Servicio(id: 'serv1', nombre: 'WiFi', iconoUrlOrCode: 'wifi'),
      const Servicio(id: 'serv2', nombre: 'Desayuno', iconoUrlOrCode: 'free_breakfast'),
      const Servicio(id: 'serv3', nombre: 'Tour Local', iconoUrlOrCode: 'tour'),
      const Servicio(id: 'serv4', nombre: 'Cocina Equipada', iconoUrlOrCode: 'kitchen'),
      const Servicio(id: 'serv5', nombre: 'Estacionamiento', iconoUrlOrCode: 'local_parking'),
      const Servicio(id: 'serv6', nombre: 'Pet Friendly', iconoUrlOrCode: 'pets'),
      const Servicio(id: 'serv7', nombre: 'Lavandería', iconoUrlOrCode: 'local_laundry_service'),
    ];
  }
}
