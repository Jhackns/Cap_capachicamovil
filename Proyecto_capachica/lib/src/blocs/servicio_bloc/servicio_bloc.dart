import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/servicio/servicio_model.dart';
import '../../services/servicio_service/servicio_service.dart'; // Placeholder

part 'servicio_event.dart';
part 'servicio_state.dart';

class ServicioBloc extends Bloc<ServicioEvent, ServicioState> {
  final ServicioService _servicioService;

  ServicioBloc(this._servicioService) : super(ServiciosInitial()) {
    on<LoadMasterServicios>(_onLoadMasterServicios);
    on<LoadServiciosForAlojamiento>(_onLoadServiciosForAlojamiento);
    on<CreateMasterServicio>(_onCreateMasterServicio);
    on<UpdateMasterServicio>(_onUpdateMasterServicio);
    on<DeleteMasterServicio>(_onDeleteMasterServicio);
    on<LinkServicioToAlojamiento>(_onLinkServicioToAlojamiento);
    on<UnlinkServicioFromAlojamiento>(_onUnlinkServicioFromAlojamiento);
  }

  Future<void> _onLoadMasterServicios(LoadMasterServicios event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // final servicios = await _servicioService.getMasterServicios();
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate
      final mockServicios = _getMockMasterServicios();
      emit(MasterServiciosLoaded(servicios: mockServicios));
    } catch (e) {
      emit(ServiciosError(message: e.toString()));
    }
  }

  Future<void> _onLoadServiciosForAlojamiento(LoadServiciosForAlojamiento event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // final servicios = await _servicioService.getServiciosForAlojamiento(event.alojamientoId);
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate
      // This should ideally return Servicio objects with their specific details for the alojamiento
      final mockServicios = _getMockServiciosForAlojamiento(event.alojamientoId);
      emit(AlojamientoServiciosLoaded(servicios: mockServicios));
    } catch (e) {
      emit(ServiciosError(message: e.toString()));
    }
  }

  Future<void> _onCreateMasterServicio(CreateMasterServicio event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading()); // Or a specific 'ServicioOperationLoading'
    try {
      // final nuevoServicio = await _servicioService.createMasterServicio(event.nombre, event.descripcion, event.iconoUrlOrCode);
      await Future.delayed(const Duration(milliseconds: 500));
      final nuevoServicio = Servicio(id: 'serv_new_${DateTime.now().millisecondsSinceEpoch}', nombre: event.nombre, descripcion: event.descripcion, iconoUrlOrCode: event.iconoUrlOrCode);
      emit(ServicioOperationSuccess(message: 'Servicio maestro creado.', data: nuevoServicio));
      add(LoadMasterServicios()); // Refresh list
    } catch (e) {
      emit(ServicioOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateMasterServicio(UpdateMasterServicio event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // final actualizadoServicio = await _servicioService.updateMasterServicio(event.servicioId, event.nombre, event.descripcion, event.iconoUrlOrCode);
      await Future.delayed(const Duration(milliseconds: 500));
      final actualizadoServicio = Servicio(id: event.servicioId, nombre: event.nombre, descripcion: event.descripcion, iconoUrlOrCode: event.iconoUrlOrCode);
      emit(ServicioOperationSuccess(message: 'Servicio maestro actualizado.', data: actualizadoServicio));
      add(LoadMasterServicios()); // Refresh list
    } catch (e) {
      emit(ServicioOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onDeleteMasterServicio(DeleteMasterServicio event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // await _servicioService.deleteMasterServicio(event.servicioId);
      await Future.delayed(const Duration(milliseconds: 500));
      emit(const ServicioOperationSuccess(message: 'Servicio maestro eliminado.'));
      add(LoadMasterServicios()); // Refresh list
    } catch (e) {
      emit(ServicioOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onLinkServicioToAlojamiento(LinkServicioToAlojamiento event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // final link = await _servicioService.linkServicio(event.alojamientoId, event.servicioId, event.detallesAdicionales, event.costoExtra);
      await Future.delayed(const Duration(milliseconds: 300));
      // In a real app, the service might return the AlojamientoServicio object
      emit(const ServicioOperationSuccess(message: 'Servicio enlazado al alojamiento.'));
      // Optionally, reload services for that alojamiento:
      // add(LoadServiciosForAlojamiento(alojamientoId: event.alojamientoId));
    } catch (e) {
      emit(ServicioOperationFailure(message: e.toString()));
    }
  }

  Future<void> _onUnlinkServicioFromAlojamiento(UnlinkServicioFromAlojamiento event, Emitter<ServicioState> emit) async {
    emit(ServiciosLoading());
    try {
      // await _servicioService.unlinkServicio(event.alojamientoServicioId);
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const ServicioOperationSuccess(message: 'Servicio desenlazado del alojamiento.'));
      // Optionally, reload services for the affected alojamiento if you know its ID
    } catch (e) {
      emit(ServicioOperationFailure(message: e.toString()));
    }
  }

  // Mock data helpers
  List<Servicio> _getMockMasterServicios() {
    return [
      const Servicio(id: 'serv1', nombre: 'WiFi', descripcion: 'Acceso a internet inalámbrico', iconoUrlOrCode: 'wifi'),
      const Servicio(id: 'serv2', nombre: 'Desayuno', descripcion: 'Desayuno continental incluido', iconoUrlOrCode: 'free_breakfast'),
      const Servicio(id: 'serv3', nombre: 'Tour Local', descripcion: 'Tour guiado por la comunidad', iconoUrlOrCode: 'tour'),
      const Servicio(id: 'serv4', nombre: 'Cocina Equipada', descripcion: 'Cocina con utensilios básicos', iconoUrlOrCode: 'kitchen'),
      const Servicio(id: 'serv5', nombre: 'Estacionamiento', descripcion: 'Estacionamiento gratuito', iconoUrlOrCode: 'local_parking'),
    ];
  }

  List<Servicio> _getMockServiciosForAlojamiento(String alojamientoId) {
    // This is simplified. In reality, you'd fetch AlojamientoServicio records
    // then fetch the corresponding Servicio details.
    if (alojamientoId == 'alo1' || alojamientoId == 'alo1_service') { // From AlojamientoBloc mock
      return [
        const Servicio(id: 'serv1', nombre: 'WiFi de Alta Velocidad', descripcion: 'Fibra óptica', iconoUrlOrCode: 'wifi'),
        const Servicio(id: 'serv2', nombre: 'Desayuno Americano', descripcion: 'Incluye huevos, pan, jugo y café', iconoUrlOrCode: 'free_breakfast'),
      ];
    } else if (alojamientoId == 'alo2' || alojamientoId == 'alo2_service') {
      return [
        const Servicio(id: 'serv2', nombre: 'Desayuno Andino', descripcion: 'Productos locales frescos', iconoUrlOrCode: 'free_breakfast'),
        const Servicio(id: 'serv3', nombre: 'Tour Cultural a Islas', descripcion: 'Visita Uros y Taquile (costo extra)', iconoUrlOrCode: 'tour'),
      ];
    }
    return [];
  }
}
