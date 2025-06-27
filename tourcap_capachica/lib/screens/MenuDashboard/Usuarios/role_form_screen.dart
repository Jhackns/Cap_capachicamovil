import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/roles/roles_bloc.dart';
import '../../../blocs/roles/roles_event.dart';
import '../../../services/dashboard_service.dart';

class RoleFormScreen extends StatefulWidget {
  final Map<String, dynamic>? role;
  final VoidCallback onCancel;

  const RoleFormScreen({this.role, required this.onCancel});

  @override
  _RoleFormScreenState createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _dashboardService = DashboardService();

  Map<String, List<Map<String, dynamic>>> _groupedPermissions = {};
  Set<String> _selectedPermissionNames = {};
  bool _isLoading = true;
  String? _error;

  bool get isEditing => widget.role != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.role!['name'];
      _selectedPermissionNames = (widget.role!['permissions'] as List<dynamic>?)
              ?.map<String>((p) => p['name'].toString())
              .toSet() ??
          {};
    }
    _fetchPermissions();
  }

  Future<void> _fetchPermissions() async {
    try {
      final permissions = await _dashboardService.getPermissions();
      final grouped = <String, List<Map<String, dynamic>>>{};
      for (var p in permissions) {
        final name = p['name'] as String;
        final groupName = name.split('_').first;
        final capitalizedGroup = groupName[0].toUpperCase() + groupName.substring(1);
        if (!grouped.containsKey(capitalizedGroup)) {
          grouped[capitalizedGroup] = [];
        }
        grouped[capitalizedGroup]!.add(p);
      }
      if (mounted) {
        setState(() {
          _groupedPermissions = grouped;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Error al cargar permisos: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final permissionsList = _selectedPermissionNames.toList();
        if (isEditing) {
          context.read<RolesBloc>().add(UpdateRole(
            roleId: widget.role!['id'],
            name: _nameController.text,
            permissions: permissionsList,
          ));
        } else {
          context.read<RolesBloc>().add(CreateRole(
            name: _nameController.text,
            permissions: permissionsList,
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Rol' : 'Crear Rol'),
        backgroundColor: const Color(0xFF9C27B0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onCancel,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del rol',
                                hintText: 'editor, manager, etc.',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, ingrese un nombre para el rol';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Permisos',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seleccione los permisos que tendrán los usuarios con este rol.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedPermissionNames = _groupedPermissions.values
                                            .expand((list) => list)
                                            .map<String>((p) => p['name'] as String)
                                            .toSet();
                                      });
                                    },
                                    child: const Text('Seleccionar Todo'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _selectedPermissionNames.clear()),
                                    child: const Text('Deseleccionar Todo'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: _groupedPermissions.entries.map((entry) {
                            final groupName = entry.key;
                            final permissionsInGroup = entry.value;
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ExpansionTile(
                                title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            child: const Text('Seleccionar Grupo'),
                                            onPressed: () => setState(() {
                                              _selectedPermissionNames.addAll(permissionsInGroup.map<String>((p) => p['name'] as String));
                                            }),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextButton(
                                            child: const Text('Quitar Grupo'),
                                            onPressed: () => setState(() {
                                              _selectedPermissionNames.removeAll(permissionsInGroup.map<String>((p) => p['name'] as String));
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...permissionsInGroup.map((permission) {
                                    final permissionName = permission['name'] as String;
                                    return CheckboxListTile(
                                      title: Text(permissionName),
                                      value: _selectedPermissionNames.contains(permissionName),
                                      onChanged: (bool? selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedPermissionNames.add(permissionName);
                                          } else {
                                            _selectedPermissionNames.remove(permissionName);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: widget.onCancel,
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9C27B0),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isEditing ? 'Guardar Cambios' : 'Crear Rol'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
} 