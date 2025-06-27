abstract class AsociacionesEvent {}

class LoadAsociaciones extends AsociacionesEvent {}

class CreateAsociacion extends AsociacionesEvent {
  final Map<String, dynamic> asociacionData;
  CreateAsociacion(this.asociacionData);
}

class UpdateAsociacion extends AsociacionesEvent {
  final int asociacionId;
  final Map<String, dynamic> asociacionData;
  UpdateAsociacion(this.asociacionId, this.asociacionData);
}

class DeleteAsociacion extends AsociacionesEvent {
  final int asociacionId;
  DeleteAsociacion(this.asociacionId);
}

class FilterAsociaciones extends AsociacionesEvent {
  final String searchQuery;
  final String status;
  final String municipalidad;
  FilterAsociaciones({required this.searchQuery, required this.status, required this.municipalidad});
} 