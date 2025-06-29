import 'package:equatable/equatable.dart';
import '../../models/entrepreneur.dart';

abstract class EntrepreneurState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EntrepreneurInitial extends EntrepreneurState {}
class EntrepreneurLoading extends EntrepreneurState {}
class EntrepreneurLoaded extends EntrepreneurState {
  final List<Entrepreneur> entrepreneurs;
  EntrepreneurLoaded(this.entrepreneurs);
  @override
  List<Object?> get props => [entrepreneurs];
}
class EntrepreneurError extends EntrepreneurState {
  final String message;
  EntrepreneurError(this.message);
  @override
  List<Object?> get props => [message];
}
class EntrepreneurSuccess extends EntrepreneurState {
  final String message;
  EntrepreneurSuccess(this.message);
  @override
  List<Object?> get props => [message];
} 