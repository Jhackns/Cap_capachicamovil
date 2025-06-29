abstract class RolesEvent {}

class LoadRoles extends RolesEvent {}

class CreateRole extends RolesEvent {
  final String name;
  final List<String> permissions;
  CreateRole({required this.name, required this.permissions});
}

class UpdateRole extends RolesEvent {
  final int roleId;
  final String name;
  final List<String> permissions;
  UpdateRole({required this.roleId, required this.name, required this.permissions});
}

class DeleteRole extends RolesEvent {
  final int roleId;
  DeleteRole(this.roleId);
} 