abstract class EntrepreneurEvent {}

class FetchEntrepreneurs extends EntrepreneurEvent {}

class GetEntrepreneurById extends EntrepreneurEvent {
  final int id;
  GetEntrepreneurById(this.id);
}

class AddEntrepreneur extends EntrepreneurEvent {
  final Map<String, dynamic> entrepreneurData;
  AddEntrepreneur(this.entrepreneurData);
}

class UpdateEntrepreneur extends EntrepreneurEvent {
  final Map<String, dynamic> entrepreneurData;
  UpdateEntrepreneur(this.entrepreneurData);
}

class DeleteEntrepreneur extends EntrepreneurEvent {
  final int id;
  DeleteEntrepreneur(this.id);
}

class ClearEntrepreneurError extends EntrepreneurEvent {} 