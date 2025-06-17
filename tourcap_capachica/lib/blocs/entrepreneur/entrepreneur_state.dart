import '../../models/entrepreneur.dart';

abstract class EntrepreneurState {}

class EntrepreneurInitial extends EntrepreneurState {}

class EntrepreneurLoading extends EntrepreneurState {}

class EntrepreneurLoaded extends EntrepreneurState {
  final List<Entrepreneur> entrepreneurs;
  EntrepreneurLoaded(this.entrepreneurs);
}

class EntrepreneurDetailLoaded extends EntrepreneurState {
  final Entrepreneur entrepreneur;
  EntrepreneurDetailLoaded(this.entrepreneur);
}

class EntrepreneurError extends EntrepreneurState {
  final String message;
  EntrepreneurError(this.message);
}

class EntrepreneurSuccess extends EntrepreneurState {
  final String message;
  EntrepreneurSuccess(this.message);
} 