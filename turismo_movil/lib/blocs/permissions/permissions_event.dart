abstract class PermissionsEvent {}

class LoadPermissions extends PermissionsEvent {}

class FilterPermissions extends PermissionsEvent {
  final String searchQuery;
  FilterPermissions({required this.searchQuery});
} 