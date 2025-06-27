abstract class AsociacionesState {}

class AsociacionesInitial extends AsociacionesState {}

class AsociacionesLoading extends AsociacionesState {}

class AsociacionesLoaded extends AsociacionesState {
  final List<Map<String, dynamic>> asociaciones;
  final List<Map<String, dynamic>> filteredAsociaciones;
  AsociacionesLoaded({required this.asociaciones, required this.filteredAsociaciones});
}

class AsociacionesError extends AsociacionesState {
  final String message;
  AsociacionesError(this.message);
}

class AsociacionOperationSuccess extends AsociacionesState {
  final String message;
  AsociacionOperationSuccess(this.message);
}

class AsociacionOperationError extends AsociacionesState {
  final String message;
  AsociacionOperationError(this.message);
} 