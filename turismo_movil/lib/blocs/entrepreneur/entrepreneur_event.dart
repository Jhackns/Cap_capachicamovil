import 'package:equatable/equatable.dart';

abstract class EntrepreneurEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadEntrepreneurs extends EntrepreneurEvent {}
class SearchEntrepreneurs extends EntrepreneurEvent {
  final String query;
  SearchEntrepreneurs(this.query);
  @override
  List<Object?> get props => [query];
}
class CreateEntrepreneur extends EntrepreneurEvent {
  final Map<String, dynamic> data;
  CreateEntrepreneur(this.data);
  @override
  List<Object?> get props => [data];
}
class UpdateEntrepreneur extends EntrepreneurEvent {
  final int id;
  final Map<String, dynamic> data;
  UpdateEntrepreneur(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}
class DeleteEntrepreneur extends EntrepreneurEvent {
  final int id;
  DeleteEntrepreneur(this.id);
  @override
  List<Object?> get props => [id];
} 