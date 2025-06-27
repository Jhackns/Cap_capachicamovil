import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import 'roles_event.dart';
import 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  final DashboardService _dashboardService = DashboardService();

  RolesBloc() : super(RolesInitial()) {
    on<LoadRoles>(_onLoadRoles);
    on<CreateRole>(_onCreateRole);
    on<UpdateRole>(_onUpdateRole);
    on<DeleteRole>(_onDeleteRole);
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      final roles = await _dashboardService.getRoles();
      emit(RolesLoaded(roles: roles));
    } catch (e) {
      emit(RolesError(e.toString()));
    }
  }

  Future<void> _onCreateRole(CreateRole event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      await _dashboardService.createRole(event.name, event.permissions);
      emit(RoleOperationSuccess('Rol creado exitosamente'));
      add(LoadRoles());
    } catch (e) {
      emit(RoleOperationError(e.toString()));
    }
  }

  Future<void> _onUpdateRole(UpdateRole event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      await _dashboardService.updateRole(event.roleId, event.name, event.permissions);
      emit(RoleOperationSuccess('Rol actualizado exitosamente'));
      add(LoadRoles());
    } catch (e) {
      emit(RoleOperationError(e.toString()));
    }
  }

  Future<void> _onDeleteRole(DeleteRole event, Emitter<RolesState> emit) async {
    emit(RolesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(RolesError('Token no disponible'));
        return;
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.getRoleUrl(event.roleId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        emit(RoleOperationSuccess('Rol eliminado exitosamente'));
        add(LoadRoles());
      } else {
        emit(RoleOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(RoleOperationError(e.toString()));
    }
  }
} 