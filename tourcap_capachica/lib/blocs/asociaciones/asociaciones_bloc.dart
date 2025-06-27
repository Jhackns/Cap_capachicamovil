import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import 'asociaciones_event.dart';
import 'asociaciones_state.dart';

class AsociacionesBloc extends Bloc<AsociacionesEvent, AsociacionesState> {
  List<Map<String, dynamic>> _asociaciones = [];
  List<Map<String, dynamic>> _filteredAsociaciones = [];

  AsociacionesBloc() : super(AsociacionesInitial()) {
    on<LoadAsociaciones>(_onLoadAsociaciones);
    on<CreateAsociacion>(_onCreateAsociacion);
    on<UpdateAsociacion>(_onUpdateAsociacion);
    on<DeleteAsociacion>(_onDeleteAsociacion);
    on<FilterAsociaciones>(_onFilterAsociaciones);
  }

  Future<void> _onLoadAsociaciones(LoadAsociaciones event, Emitter<AsociacionesState> emit) async {
    emit(AsociacionesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(AsociacionesError('Token no disponible'));
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getAsociacionesUrl()),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _asociaciones = List<Map<String, dynamic>>.from(data['data']['data']);
          _filteredAsociaciones = _asociaciones;
          emit(AsociacionesLoaded(asociaciones: _asociaciones, filteredAsociaciones: _filteredAsociaciones));
        } else {
          emit(AsociacionesError(data['message'] ?? 'Error al cargar asociaciones'));
        }
      } else {
        emit(AsociacionesError('Error: ${response.body}'));
      }
    } catch (e) {
      emit(AsociacionesError(e.toString()));
    }
  }

  Future<void> _onCreateAsociacion(CreateAsociacion event, Emitter<AsociacionesState> emit) async {
    emit(AsociacionesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(AsociacionesError('Token no disponible'));
        return;
      }

      final url = Uri.parse(ApiConfig.getAsociacionesUrl());
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Agregar campos de la asociación
      event.asociacionData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (key != 'imagen') {
            request.fields[key] = value.toString();
          }
        }
      });

      // Agregar archivo si existe
      if (event.asociacionData['imagen'] != null && event.asociacionData['imagen'] is File) {
        final file = event.asociacionData['imagen'] as File;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'imagen',
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        emit(AsociacionOperationSuccess(responseData['message'] ?? 'Asociación creada exitosamente'));
        add(LoadAsociaciones());
      } else {
        final errorData = json.decode(response.body);
        emit(AsociacionOperationError(errorData['message'] ?? 'Error al crear asociación'));
      }
    } catch (e) {
      emit(AsociacionOperationError(e.toString()));
    }
  }

  Future<void> _onUpdateAsociacion(UpdateAsociacion event, Emitter<AsociacionesState> emit) async {
    emit(AsociacionesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(AsociacionesError('Token no disponible'));
        return;
      }

      final url = Uri.parse(ApiConfig.getAsociacionUrl(event.asociacionId));
      final request = http.MultipartRequest('POST', url);
      request.fields['_method'] = 'PUT';
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Agregar campos de la asociación
      event.asociacionData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (key != 'imagen') {
            request.fields[key] = value.toString();
          }
        }
      });

      // Agregar archivo si existe
      if (event.asociacionData['imagen'] != null && event.asociacionData['imagen'] is File) {
        final file = event.asociacionData['imagen'] as File;
        final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'imagen',
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        emit(AsociacionOperationSuccess(responseData['message'] ?? 'Asociación actualizada exitosamente'));
        add(LoadAsociaciones());
      } else {
        final errorData = json.decode(response.body);
        emit(AsociacionOperationError(errorData['message'] ?? 'Error al actualizar asociación'));
      }
    } catch (e) {
      emit(AsociacionOperationError(e.toString()));
    }
  }

  Future<void> _onDeleteAsociacion(DeleteAsociacion event, Emitter<AsociacionesState> emit) async {
    emit(AsociacionesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(AsociacionesError('Token no disponible'));
        return;
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.getAsociacionUrl(event.asociacionId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        emit(AsociacionOperationSuccess(responseData['message'] ?? 'Asociación eliminada exitosamente'));
        add(LoadAsociaciones());
      } else {
        final errorData = json.decode(response.body);
        emit(AsociacionOperationError(errorData['message'] ?? 'Error al eliminar asociación'));
      }
    } catch (e) {
      emit(AsociacionOperationError(e.toString()));
    }
  }

  void _onFilterAsociaciones(FilterAsociaciones event, Emitter<AsociacionesState> emit) {
    _filteredAsociaciones = _asociaciones.where((asociacion) {
      final nombre = (asociacion['nombre'] ?? '').toString().toLowerCase();
      final descripcion = (asociacion['descripcion'] ?? '').toString().toLowerCase();
      final municipalidad = (asociacion['municipalidad']?['nombre'] ?? '').toString().toLowerCase();
      final estado = (asociacion['estado'] == true) ? 'Activas' : 'Inactivas';

      final matchesQuery = event.searchQuery.isEmpty ||
          nombre.contains(event.searchQuery.toLowerCase()) ||
          descripcion.contains(event.searchQuery.toLowerCase()) ||
          municipalidad.contains(event.searchQuery.toLowerCase());
      final matchesStatus = event.status == 'Todas' || estado == event.status;
      final matchesMunicipalidad = event.municipalidad == 'Todas' || municipalidad == event.municipalidad;

      return matchesQuery && matchesStatus && matchesMunicipalidad;
    }).toList();

    emit(AsociacionesLoaded(asociaciones: _asociaciones, filteredAsociaciones: _filteredAsociaciones));
  }
} 