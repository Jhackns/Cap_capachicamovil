abstract class PermissionsState {}

class PermissionsInitial extends PermissionsState {}

class PermissionsLoading extends PermissionsState {}

class PermissionsLoaded extends PermissionsState {
  final List<Map<String, dynamic>> permissions;
  final Map<String, List<Map<String, dynamic>>> groupedPermissions;
  final Map<String, List<Map<String, dynamic>>> filteredGroupedPermissions;
  PermissionsLoaded({
    required this.permissions,
    required this.groupedPermissions,
    required this.filteredGroupedPermissions,
  });
}

class PermissionsError extends PermissionsState {
  final String message;
  PermissionsError(this.message);
} 