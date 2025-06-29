import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  UsersBloc() : super(UsersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<ActivateUser>(_onActivateUser);
    on<DeactivateUser>(_onDeactivateUser);
    on<FilterUsers>(_onFilterUsers);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final users = await _dashboardService.getUsers();
      _users = users;
      _filteredUsers = users;
      emit(UsersLoaded(users: users, filteredUsers: users));
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(UsersError('Token no disponible'));
        return;
      }

      final url = Uri.parse(ApiConfig.getUsersUrl());
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Agregar campos del usuario
      event.userData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (key == 'roles' && value is List) {
            print('DEBUG: Enviando roles: $value'); // Debug log
            for (int i = 0; i < value.length; i++) {
              final role = value[i];
              print('DEBUG: Agregando rol: $role'); // Debug log
              request.fields['roles[$i]'] = role.toString();
            }
          } else if (key != 'profileImage') {
            request.fields[key] = value.toString();
          }
        }
      });

      // Debug: imprimir todos los campos que se van a enviar
      print('DEBUG: Campos a enviar: ${request.fields}');

      // Agregar archivo si existe
      if (event.userData['profileImage'] != null && event.userData['profileImage'] is File) {
        final file = event.userData['profileImage'] as File;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'foto_perfil',
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(UserOperationSuccess('Usuario creado exitosamente'));
        add(LoadUsers());
      } else {
        emit(UserOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(UserOperationError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(UsersError('Token no disponible'));
        return;
      }

      final url = Uri.parse(ApiConfig.getUserByIdUrl(event.userId));
      final request = http.MultipartRequest('POST', url);
      request.fields['_method'] = 'PUT';
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Agregar campos del usuario
      event.userData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (key == 'roles' && value is List) {
            print('DEBUG: Enviando roles: $value'); // Debug log
            for (int i = 0; i < value.length; i++) {
              final role = value[i];
              print('DEBUG: Agregando rol: $role'); // Debug log
              request.fields['roles[$i]'] = role.toString();
            }
          } else if (key != 'profileImage') {
            request.fields[key] = value.toString();
          }
        }
      });

      // Debug: imprimir todos los campos que se van a enviar
      print('DEBUG: Campos a enviar: ${request.fields}');

      // Agregar archivo si existe
      if (event.userData['profileImage'] != null && event.userData['profileImage'] is File) {
        final file = event.userData['profileImage'] as File;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'foto_perfil',
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        emit(UserOperationSuccess('Usuario actualizado exitosamente'));
        add(LoadUsers());
      } else {
        emit(UserOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(UserOperationError(e.toString()));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(UsersError('Token no disponible'));
        return;
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.getUserByIdUrl(event.userId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        emit(UserOperationSuccess('Usuario eliminado exitosamente'));
        add(LoadUsers());
      } else {
        emit(UserOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(UserOperationError(e.toString()));
    }
  }

  Future<void> _onActivateUser(ActivateUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(UsersError('Token no disponible'));
        return;
      }

      final url = ApiConfig.getUserByIdUrl(event.userId) + '/activate';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        emit(UserOperationSuccess('Usuario activado exitosamente'));
        add(LoadUsers());
      } else {
        emit(UserOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(UserOperationError(e.toString()));
    }
  }

  Future<void> _onDeactivateUser(DeactivateUser event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(UsersError('Token no disponible'));
        return;
      }

      final url = ApiConfig.getUserByIdUrl(event.userId) + '/deactivate';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        emit(UserOperationSuccess('Usuario desactivado exitosamente'));
        add(LoadUsers());
      } else {
        emit(UserOperationError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(UserOperationError(e.toString()));
    }
  }

  void _onFilterUsers(FilterUsers event, Emitter<UsersState> emit) {
    _filteredUsers = _users.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final roles = (user['roles'] as List? ?? []).map((r) {
        if (r is Map && r.containsKey('name')) return r['name'].toString();
        return r.toString();
      }).toList();
      final status = (user['active'] == true) ? 'Activos' : 'Inactivos';

      final matchesQuery = event.searchQuery.isEmpty ||
          name.contains(event.searchQuery.toLowerCase()) ||
          email.contains(event.searchQuery.toLowerCase());
      final matchesStatus = event.status == 'Todos' || status == event.status;
      final matchesRole = event.role == 'Todos' || roles.contains(event.role);

      return matchesQuery && matchesStatus && matchesRole;
    }).toList();

    emit(UsersLoaded(users: _users, filteredUsers: _filteredUsers));
  }
} 