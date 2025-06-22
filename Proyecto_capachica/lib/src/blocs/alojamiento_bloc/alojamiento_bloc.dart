import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/alojamiento/alojamiento_model.dart';
import '../../models/alojamiento/categoria_alojamiento_model.dart';
import '../../models/alojamiento/direccion_model.dart';
import '../../models/alojamiento/disponibilidad_model.dart';
import '../../models/alojamiento/foto_alojamiento_model.dart';
import '../../services/alojamiento_service/alojamiento_service.dart'; // Placeholder

part 'alojamiento_event.dart';
part 'alojamiento_state.dart';

class AlojamientoBloc extends Bloc<AlojamientoEvent, AlojamientoState> {
  final AlojamientoService _alojamientoService; // Placeholder, will be injected

  AlojamientoBloc(this._alojamientoService) : super(AlojamientosInitial()) {
    on<LoadAlojamientos>(_onLoadAlojamientos);
    on<FilterAlojamientos>(_onFilterAlojamientos);
    on<LoadAlojamientoDetails>(_onLoadAlojamientoDetails);
    on<CreateAlojamiento>(_onCreateAlojamiento);
    on<UpdateAlojamiento>(_onUpdateAlojamiento);
    on<DeleteAlojamiento>(_onDeleteAlojamiento);
  }

  Future<void> _onLoadAlojamientos(LoadAlojamientos event, Emitter<AlojamientoState> emit) async {
    emit(AlojamientosLoading());
    try {
      // final alojamientos = await _alojamientoService.getAlojamientos(filters: event.filters);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      final mockAlojamientos = _getMockAlojamientos(); // Use a helper for mock data
      emit(AlojamientosLoaded(alojamientos: mockAlojamientos));
    } catch (e) {
      emit(AlojamientosError(message: e.toString()));
    }
  }

  Future<void> _onFilterAlojamientos(FilterAlojamientos event, Emitter<AlojamientoState> emit) async {
    emit(AlojamientosLoading());
    try {
      // final alojamientos = await _alojamientoService.getAlojamientos(
      //   categoriaId: event.categoriaId,
      //   servicioIds: event.servicioIds,
      //   minPrice: event.minPrice,
      //   maxPrice: event.maxPrice,
      //   searchTerm: event.searchTerm
      // );
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      // Simple mock filtering:
      var mockAlojamientos = _getMockAlojamientos();
      if (event.searchTerm != null && event.searchTerm!.isNotEmpty) {
        mockAlojamientos = mockAlojamientos.where((a) => a.nombre.toLowerCase().contains(event.searchTerm!.toLowerCase())).toList();
      }
      if (event.categoriaId != null) {
        mockAlojamientos = mockAlojamientos.where((a) => a.categoria.id == event.categoriaId).toList();
      }
      // Add more mock filters here
      emit(AlojamientosLoaded(alojamientos: mockAlojamientos));
    } catch (e) {
      emit(AlojamientosError(message: e.toString()));
    }
  }

  Future<void> _onLoadAlojamientoDetails(LoadAlojamientoDetails event, Emitter<AlojamientoState> emit) async {
    emit(AlojamientoDetailsLoading(alojamientoId: event.alojamientoId));
    try {
      // final alojamiento = await _alojamientoService.getAlojamientoDetails(event.alojamientoId);
      // final servicios = await _alojamientoService.getServiciosForAlojamiento(event.alojamientoId);
      // final resenas = await _alojamientoService.getResenasForAlojamiento(event.alojamientoId);
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      final mockAlojamiento = _getMockAlojamientos().firstWhere((a) => a.id == event.alojamientoId, orElse: () => _getMockAlojamientos().first);
      emit(AlojamientoDetailsLoaded(
        alojamiento: mockAlojamiento
        // serviciosDetallados: mockServicios,
        // resenas: mockResenas
      ));
    } catch (e) {
      emit(AlojamientosError(message: e.toString()));
    }
  }

  Future<void> _onCreateAlojamiento(CreateAlojamiento event, Emitter<AlojamientoState> emit) async {
    emit(const AlojamientoOperationLoading(message: 'Creating Alojamiento...'));
    try {
      // final nuevoAlojamiento = await _alojamientoService.createAlojamiento(event.alojamientoData);
      await Future.delayed(const Duration(seconds: 1));
      // Simulate creation:
      final nuevoAlojamiento = Alojamiento(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: event.alojamientoData['nombre'] ?? 'New Mock Alojamiento',
        descripcion: event.alojamientoData['descripcion'] ?? 'Description',
        precioPorNoche: event.alojamientoData['precioPorNoche'] ?? 50.0,
        anfitrionId: 'admin_user_id', // Placeholder
        categoria: event.alojamientoData['categoria'] ?? const CategoriaAlojamiento(id: 'cat1', nombre: 'Cabaña'),
        direccion: event.alojamientoData['direccion'] ?? const Direccion(id: 'dir1', calle: 'Main St', ciudad: 'Capachica', region: 'Puno', pais: 'Perú'),
        fotos: [],
        idServicios: [],
        periodosDisponibilidad: []
      );
      emit(AlojamientoOperationSuccess(message: 'Alojamiento created successfully', alojamiento: nuevoAlojamiento));
      // Optionally, reload all alojamientos or add to existing list
      add(LoadAlojamientos());
    } catch (e) {
      emit(AlojamientoOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateAlojamiento(UpdateAlojamiento event, Emitter<AlojamientoState> emit) async {
    emit(const AlojamientoOperationLoading(message: 'Updating Alojamiento...'));
    try {
      // final actualizadoAlojamiento = await _alojamientoService.updateAlojamiento(event.alojamientoId, event.alojamientoData);
      await Future.delayed(const Duration(seconds: 1));
      // Simulate update:
      final actualizadoAlojamiento = Alojamiento(
        id: event.alojamientoId,
        nombre: event.alojamientoData['nombre'] ?? 'Updated Mock Alojamiento',
        descripcion: event.alojamientoData['descripcion'] ?? 'Updated Description',
        precioPorNoche: event.alojamientoData['precioPorNoche'] ?? 75.0,
        anfitrionId: 'admin_user_id', // Placeholder
        categoria: event.alojamientoData['categoria'] ?? const CategoriaAlojamiento(id: 'cat1', nombre: 'Cabaña'),
        direccion: event.alojamientoData['direccion'] ?? const Direccion(id: 'dir1', calle: 'Main St', ciudad: 'Capachica', region: 'Puno', pais: 'Perú'),
        fotos: [],
        idServicios: [],
        periodosDisponibilidad: []
      );
      emit(AlojamientoOperationSuccess(message: 'Alojamiento updated successfully', alojamiento: actualizadoAlojamiento));
      add(LoadAlojamientos()); // Reload list
    } catch (e) {
      emit(AlojamientoOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onDeleteAlojamiento(DeleteAlojamiento event, Emitter<AlojamientoState> emit) async {
    emit(const AlojamientoOperationLoading(message: 'Deleting Alojamiento...'));
    try {
      // await _alojamientoService.deleteAlojamiento(event.alojamientoId);
      await Future.delayed(const Duration(seconds: 1));
      emit(const AlojamientoOperationSuccess(message: 'Alojamiento deleted successfully'));
      add(LoadAlojamientos()); // Reload list
    } catch (e) {
      emit(AlojamientoOperationFailure(message: e.toString()));
    }
  }

  // Helper for mock data
  List<Alojamiento> _getMockAlojamientos() {
    final categoriaCabana = const CategoriaAlojamiento(id: 'cat1', nombre: 'Cabaña');
    final categoriaCasaRural = const CategoriaAlojamiento(id: 'cat2', nombre: 'Casa Rural');
    final direccion1 = const Direccion(id: 'dir1', calle: 'Principal S/N', ciudad: 'Capachica', region: 'Puno', pais: 'Perú', latitud: -15.65, longitud: -69.83);
    final direccion2 = const Direccion(id: 'dir2', calle: 'Orilla del Lago', ciudad: 'Llachon', region: 'Puno', pais: 'Perú', latitud: -15.60, longitud: -69.90);

    return [
      Alojamiento(
        id: 'alo1',
        nombre: 'Cabaña del Sol',
        descripcion: 'Hermosa cabaña con vista al lago Titicaca.',
        precioPorNoche: 150.00,
        anfitrionId: 'user_host_1',
        categoria: categoriaCabana,
        direccion: direccion1,
        fotos: [const FotoAlojamiento(id: 'f1', alojamientoId: 'alo1', urlFoto: 'https://via.placeholder.com/300x200.png?text=Cabaña+Sol+1')],
        idServicios: ['serv1', 'serv2'], // Wifi, Desayuno
        periodosDisponibilidad: [
          PeriodoDisponibilidad(id: 'disp1', alojamientoId: 'alo1', fechaInicio: DateTime.now().add(const Duration(days: 1)), fechaFin: DateTime.now().add(const Duration(days: 10)), estaDisponible: true)
        ],
        calificacionPromedio: 4.5
      ),
      Alojamiento(
        id: 'alo2',
        nombre: 'Casa Rural Pacha Mama',
        descripcion: 'Experiencia auténtica en una casa rural comunitaria.',
        precioPorNoche: 120.00,
        anfitrionId: 'user_host_2',
        categoria: categoriaCasaRural,
        direccion: direccion2,
        fotos: [const FotoAlojamiento(id: 'f2', alojamientoId: 'alo2', urlFoto: 'https://via.placeholder.com/300x200.png?text=Casa+Pacha+Mama+1')],
        idServicios: ['serv2', 'serv3'], // Desayuno, Tour Local
        periodosDisponibilidad: [
          PeriodoDisponibilidad(id: 'disp2', alojamientoId: 'alo2', fechaInicio: DateTime.now().add(const Duration(days: 5)), fechaFin: DateTime.now().add(const Duration(days: 15)), estaDisponible: true)
        ],
        calificacionPromedio: 4.8
      ),
    ];
  }
}
