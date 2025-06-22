
import '../../models/alojamiento/alojamiento_model.dart';
// Import other models if needed for detailed responses
import '../../models/alojamiento/categoria_alojamiento_model.dart';
import '../../models/alojamiento/direccion_model.dart';
import '../../models/alojamiento/foto_alojamiento_model.dart';
import '../../models/alojamiento/disponibilidad_model.dart';


class AlojamientoService {
  AlojamientoService();

  Future<List<Alojamiento>> getAlojamientos({Map<String, dynamic>? filters}) async {
    // Simulate API call
    print('AlojamientoService (Placeholder): Fetching alojamientos with filters: $filters');
    await Future.delayed(const Duration(seconds: 1));
    // Return mock data, actual implementation would filter based on params
    return _getMockAlojamientosFromService();
  }

  Future<Alojamiento> getAlojamientoDetails(String alojamientoId) async {
    // Simulate API call
    print('AlojamientoService (Placeholder): Fetching details for alojamiento ID: $alojamientoId');
    await Future.delayed(const Duration(seconds: 1));
    final alojamientos = _getMockAlojamientosFromService();
    return alojamientos.firstWhere((a) => a.id == alojamientoId,
        orElse: () => throw Exception('Alojamiento not found with ID $alojamientoId'));
  }

  Future<Alojamiento> createAlojamiento(Map<String, dynamic> data) async {
    // Simulate API call
    print('AlojamientoService (Placeholder): Creating alojamiento with data: $data');
    await Future.delayed(const Duration(seconds: 1));
    // Return a new mock alojamiento based on data
    return Alojamiento(
      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
      nombre: data['nombre'] ?? 'New Service Alojamiento',
      // ... fill other fields from data or with defaults
      descripcion: data['descripcion'] ?? 'Default Description',
      precioPorNoche: data['precioPorNoche'] ?? 0.0,
      anfitrionId: data['anfitrionId'] ?? 'default_host_id',
      categoria: data['categoria'] as CategoriaAlojamiento? ?? const CategoriaAlojamiento(id: 'cat_default', nombre: 'Default Category'),
      direccion: data['direccion'] as Direccion? ?? const Direccion(id: 'dir_default', calle: 'Default St', ciudad: 'Default City', region: 'Default Region', pais: 'Default Country'),
      fotos: data['fotos'] as List<FotoAlojamiento>? ?? [],
      idServicios: data['idServicios'] as List<String>? ?? [],
      periodosDisponibilidad: data['periodosDisponibilidad'] as List<PeriodoDisponibilidad>? ?? []
    );
  }

  Future<Alojamiento> updateAlojamiento(String id, Map<String, dynamic> data) async {
    // Simulate API call
    print('AlojamientoService (Placeholder): Updating alojamiento ID $id with data: $data');
    await Future.delayed(const Duration(seconds: 1));
    // Return an updated mock alojamiento
     return Alojamiento(
      id: id,
      nombre: data['nombre'] ?? 'Updated Service Alojamiento',
      // ... fill other fields from data or with defaults
      descripcion: data['descripcion'] ?? 'Default Description',
      precioPorNoche: data['precioPorNoche'] ?? 0.0,
      anfitrionId: data['anfitrionId'] ?? 'default_host_id',
      categoria: data['categoria'] as CategoriaAlojamiento? ?? const CategoriaAlojamiento(id: 'cat_default', nombre: 'Default Category'),
      direccion: data['direccion'] as Direccion? ?? const Direccion(id: 'dir_default', calle: 'Default St', ciudad: 'Default City', region: 'Default Region', pais: 'Default Country'),
      fotos: data['fotos'] as List<FotoAlojamiento>? ?? [],
      idServicios: data['idServicios'] as List<String>? ?? [],
      periodosDisponibilidad: data['periodosDisponibilidad'] as List<PeriodoDisponibilidad>? ?? []
    );
  }

  Future<void> deleteAlojamiento(String id) async {
    // Simulate API call
    print('AlojamientoService (Placeholder): Deleting alojamiento ID: $id');
    await Future.delayed(const Duration(seconds: 1));
    // No return value needed for delete
  }

  // Helper method to provide mock data within the service
  List<Alojamiento> _getMockAlojamientosFromService() {
     // Re-use the same mock data structure as in the BLoC for consistency in this placeholder phase
    final categoriaCabana = const CategoriaAlojamiento(id: 'cat1', nombre: 'Cabaña');
    final categoriaCasaRural = const CategoriaAlojamiento(id: 'cat2', nombre: 'Casa Rural');
    final direccion1 = const Direccion(id: 'dir1', calle: 'Principal S/N', ciudad: 'Capachica', region: 'Puno', pais: 'Perú', latitud: -15.65, longitud: -69.83);
    final direccion2 = const Direccion(id: 'dir2', calle: 'Orilla del Lago', ciudad: 'Llachon', region: 'Puno', pais: 'Perú', latitud: -15.60, longitud: -69.90);

    return [
      Alojamiento(
        id: 'alo1_service', // Different ID to distinguish from BLoC's direct mock if needed
        nombre: 'Cabaña del Sol (Service)',
        descripcion: 'Hermosa cabaña con vista al lago Titicaca.',
        precioPorNoche: 150.00,
        anfitrionId: 'user_host_1',
        categoria: categoriaCabana,
        direccion: direccion1,
        fotos: [const FotoAlojamiento(id: 'f1_s', alojamientoId: 'alo1_service', urlFoto: 'https://via.placeholder.com/300x200.png?text=Cabaña+Sol+Service')],
        idServicios: ['serv1', 'serv2'],
        periodosDisponibilidad: [
          PeriodoDisponibilidad(id: 'disp1_s', alojamientoId: 'alo1_service', fechaInicio: DateTime.now().add(const Duration(days: 1)), fechaFin: DateTime.now().add(const Duration(days: 10)), estaDisponible: true)
        ],
        calificacionPromedio: 4.5
      ),
      Alojamiento(
        id: 'alo2_service',
        nombre: 'Casa Rural Pacha Mama (Service)',
        descripcion: 'Experiencia auténtica en una casa rural comunitaria.',
        precioPorNoche: 120.00,
        anfitrionId: 'user_host_2',
        categoria: categoriaCasaRural,
        direccion: direccion2,
        fotos: [const FotoAlojamiento(id: 'f2_s', alojamientoId: 'alo2_service', urlFoto: 'https://via.placeholder.com/300x200.png?text=Casa+Pacha+Service')],
        idServicios: ['serv2', 'serv3'],
        periodosDisponibilidad: [
          PeriodoDisponibilidad(id: 'disp2_s', alojamientoId: 'alo2_service', fechaInicio: DateTime.now().add(const Duration(days: 5)), fechaFin: DateTime.now().add(const Duration(days: 15)), estaDisponible: true)
        ],
        calificacionPromedio: 4.8
      ),
    ];
  }
}
