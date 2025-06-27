abstract class RolesState {}

class RolesInitial extends RolesState {}

class RolesLoading extends RolesState {}

class RolesLoaded extends RolesState {
  final List<Map<String, dynamic>> roles;
  RolesLoaded({required this.roles});
}

class RolesError extends RolesState {
  final String message;
  RolesError(this.message);
}

class RoleOperationSuccess extends RolesState {
  final String message;
  RoleOperationSuccess(this.message);
}

class RoleOperationError extends RolesState {
  final String message;
  RoleOperationError(this.message);
} 