part of 'alojamiento_bloc.dart';

abstract class AlojamientoEvent extends Equatable {
  const AlojamientoEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlojamientos extends AlojamientoEvent {
  // Potential filters can be passed here if not using a separate FilterAlojamientos event
  // final Map<String, dynamic>? filters;
  // const LoadAlojamientos({this.filters});
}

class FilterAlojamientos extends AlojamientoEvent {
  final String? categoriaId;
  final List<String>? servicioIds;
  // Add other filter criteria like price range, location (e.g., city or region)
  final double? minPrice;
  final double? maxPrice;
  final String? searchTerm;

  const FilterAlojamientos({
    this.categoriaId,
    this.servicioIds,
    this.minPrice,
    this.maxPrice,
    this.searchTerm,
  });

  @override
  List<Object?> get props => [categoriaId, servicioIds, minPrice, maxPrice, searchTerm];
}

class LoadAlojamientoDetails extends AlojamientoEvent {
  final String alojamientoId;

  const LoadAlojamientoDetails({required this.alojamientoId});

  @override
  List<Object> get props => [alojamientoId];
}

// Admin Events
class CreateAlojamiento extends AlojamientoEvent {
  final Map<String, dynamic> alojamientoData; // Simplified for now
  // In a real app, this would likely be a full Alojamiento object or specific fields

  const CreateAlojamiento({required this.alojamientoData});

  @override
  List<Object> get props => [alojamientoData];
}

class UpdateAlojamiento extends AlojamientoEvent {
  final String alojamientoId;
  final Map<String, dynamic> alojamientoData; // Simplified

  const UpdateAlojamiento({required this.alojamientoId, required this.alojamientoData});

  @override
  List<Object> get props => [alojamientoId, alojamientoData];
}

class DeleteAlojamiento extends AlojamientoEvent {
  final String alojamientoId;

  const DeleteAlojamiento({required this.alojamientoId});

  @override
  List<Object> get props => [alojamientoId];
}
