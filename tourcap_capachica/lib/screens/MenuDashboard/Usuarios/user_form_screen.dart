import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../blocs/users/users_bloc.dart';
import '../../../blocs/users/users_event.dart';
import '../../../blocs/users/users_state.dart';

class UserFormScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final VoidCallback? onCancel;

  const UserFormScreen({this.user, this.onCancel});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Campos del formulario
  String _name = '';
  String _email = '';
  String _phone = '';
  String _country = '';
  String _address = '';
  DateTime? _birthDate;
  String? _gender;
  String? _preferredLanguage;
  String _password = '';
  String _confirmPassword = '';
  bool _active = true;
  List<String> _selectedRoles = [];

  bool get isEditing => widget.user != null;

  final Map<String, String> _genderOptions = {
    'male': 'Masculino',
    'female': 'Femenino',
    'other': 'Otro',
    'prefer_not_to_say': 'Prefiero no decirlo',
  };
  final List<String> _languageOptions = ['es', 'en', 'fr', 'pt'];
  final Map<String, String> _languageLabels = {
    'es': 'Español',
    'en': 'Inglés',
    'fr': 'Francés',
    'pt': 'Portugués',
  };
  final List<Map<String, dynamic>> _rolesOptions = [
    {'id': 1, 'name': 'admin'},
    {'id': 2, 'name': 'user'},
    {'id': 3, 'name': 'emprendedor'},
    {'id': 4, 'name': 'moderador'},
  ];

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final user = widget.user!;
      _name = user['name'] ?? '';
      _email = user['email'] ?? '';
      _phone = user['phone'] ?? '';
      _country = user['country'] ?? '';
      _address = user['address'] ?? '';
      _birthDate = user['birth_date'] != null ? DateTime.tryParse(user['birth_date']) : null;

      final genderValue = user['gender']?.toString().toLowerCase();
      if (_genderOptions.keys.contains(genderValue)) {
        _gender = genderValue;
      } else {
        _gender = null;
      }

      final lang = user['preferred_language'];
      if (_languageOptions.contains(lang)) {
        _preferredLanguage = lang;
      } else if (_languageLabels.containsValue(lang)) {
        _preferredLanguage = _languageLabels.entries
            .firstWhere((e) => e.value == lang, orElse: () => const MapEntry('es', 'Español'))
            .key;
      } else {
        _preferredLanguage = null;
      }
      _active = user['active'] ?? true;
      _selectedRoles = List<String>.from((user['roles'] ?? []).map((role) {
        if (role is Map && role.containsKey('name')) return role['name'].toString();
        return role.toString();
      }));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_password.isNotEmpty && _password != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    final userData = {
      'name': _name,
      'email': _email,
      'phone': _phone,
      'country': _country,
      'address': _address,
      'birth_date': _birthDate?.toIso8601String().split('T').first,
      'gender': _gender,
      'preferred_language': _preferredLanguage,
      'active': _active ? '1' : '0',
      'roles': _selectedRoles,
      if (_profileImage != null) 'profileImage': _profileImage,
    };

    if (!isEditing && _password.isNotEmpty) {
      userData['password'] = _password;
    }

    if (isEditing) {
      context.read<UsersBloc>().add(UpdateUser(widget.user!['id'], userData));
    } else {
      context.read<UsersBloc>().add(CreateUser(userData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Usuario' : 'Crear Usuario'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel ?? () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UserOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            if (widget.onCancel != null) widget.onCancel!();
          } else if (state is UserOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : (isEditing && widget.user!['foto_perfil'] != null
                                ? NetworkImage(widget.user!['foto_perfil'])
                                : null),
                        child: _profileImage == null && (widget.user?['foto_perfil'] == null)
                            ? const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C27B0),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese el nombre completo' : null,
                  onChanged: (v) => _name = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _email,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese el correo' : null,
                  onChanged: (v) => _email = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                  keyboardType: TextInputType.phone,
                  onChanged: (v) => _phone = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _country,
                  decoration: const InputDecoration(labelText: 'País'),
                  onChanged: (v) => _country = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _address,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  onChanged: (v) => _address = v,
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _birthDate = picked);
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Fecha de nacimiento',
                        hintText: 'dd/mm/aaaa',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _birthDate != null
                            ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                            : '',
                      ),
                      validator: (v) => _birthDate == null && !isEditing ? 'Seleccione la fecha de nacimiento' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: _genderOptions.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v),
                  decoration: const InputDecoration(labelText: 'Género'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _languageOptions.contains(_preferredLanguage) ? _preferredLanguage : null,
                  items: _languageOptions
                      .map((l) => DropdownMenuItem(
                            value: l,
                            child: Text(_languageLabels[l] ?? l.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _preferredLanguage = v),
                  decoration: const InputDecoration(labelText: 'Idioma preferido'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    helperText: isEditing ? 'Dejar en blanco para no cambiar' : null,
                  ),
                  obscureText: true,
                  validator: (v) => !isEditing && (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                  onChanged: (v) => _password = v,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                  obscureText: true,
                  validator: (v) => _password.isNotEmpty && v != _password ? 'Las contraseñas no coinciden' : null,
                  onChanged: (v) => _confirmPassword = v,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<bool>(
                  value: _active,
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Activo')),
                    DropdownMenuItem(value: false, child: Text('Inactivo')),
                  ],
                  onChanged: (v) => setState(() => _active = v ?? true),
                  decoration: const InputDecoration(labelText: 'Estado'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Roles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: _rolesOptions
                      .map((role) => FilterChip(
                            label: Text('${role['name']} (ID: ${role['id']})'),
                            selected: _selectedRoles.contains(role['name']),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedRoles.add(role['name']);
                                } else {
                                  _selectedRoles.remove(role['name']);
                                }
                              });
                            },
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: widget.onCancel ?? () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isEditing ? 'Guardar Cambios' : 'Crear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 