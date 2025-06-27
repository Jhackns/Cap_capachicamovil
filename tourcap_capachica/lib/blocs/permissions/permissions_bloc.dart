import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/dashboard_service.dart';
import 'permissions_event.dart';
import 'permissions_state.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _permissions = [];
  Map<String, List<Map<String, dynamic>>> _groupedPermissions = {};

  PermissionsBloc() : super(PermissionsInitial()) {
    on<LoadPermissions>(_onLoadPermissions);
    on<FilterPermissions>(_onFilterPermissions);
  }

  Future<void> _onLoadPermissions(LoadPermissions event, Emitter<PermissionsState> emit) async {
    emit(PermissionsLoading());
    try {
      final permissions = await _dashboardService.getPermissions();
      _permissions = permissions;
      _groupedPermissions = _groupPermissions(permissions);
      emit(PermissionsLoaded(
        permissions: permissions,
        groupedPermissions: _groupedPermissions,
        filteredGroupedPermissions: _groupedPermissions,
      ));
    } catch (e) {
      emit(PermissionsError(e.toString()));
    }
  }

  void _onFilterPermissions(FilterPermissions event, Emitter<PermissionsState> emit) {
    if (event.searchQuery.isEmpty) {
      emit(PermissionsLoaded(
        permissions: _permissions,
        groupedPermissions: _groupedPermissions,
        filteredGroupedPermissions: _groupedPermissions,
      ));
    } else {
      final filtered = <String, List<Map<String, dynamic>>>{};
      _groupedPermissions.forEach((group, perms) {
        final matches = perms.where((p) => 
          (p['name'] as String).toLowerCase().contains(event.searchQuery.toLowerCase())
        ).toList();
        if (matches.isNotEmpty) filtered[group] = matches;
      });
      
      emit(PermissionsLoaded(
        permissions: _permissions,
        groupedPermissions: _groupedPermissions,
        filteredGroupedPermissions: filtered,
      ));
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupPermissions(List<Map<String, dynamic>> permissions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var p in permissions) {
      final name = p['name'] as String;
      final groupName = name.split('_').first;
      final capitalizedGroup = groupName[0].toUpperCase() + groupName.substring(1);
      if (!grouped.containsKey(capitalizedGroup)) {
        grouped[capitalizedGroup] = [];
      }
      grouped[capitalizedGroup]!.add(p);
    }
    return grouped;
  }
} 