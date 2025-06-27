import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/roles/roles_bloc.dart';
import '../../../blocs/roles/roles_event.dart';
import '../../../blocs/roles/roles_state.dart';
import 'role_form_screen.dart';

class RolesManagementScreen extends StatefulWidget {
  const RolesManagementScreen({Key? key}) : super(key: key);

  @override
  State<RolesManagementScreen> createState() => _RolesManagementScreenState();
}

class _RolesManagementScreenState extends State<RolesManagementScreen> {
  bool _showRoleForm = false;
  Map<String, dynamic>? _selectedRole;

  @override
  void initState() {
    super.initState();
    context.read<RolesBloc>().add(LoadRoles());
  }

  void _refreshRoles() {
    setState(() {
      _showRoleForm = false;
      _selectedRole = null;
    });
    context.read<RolesBloc>().add(LoadRoles());
  }

  @override
  Widget build(BuildContext context) {
    if (_showRoleForm) {
      return RoleFormScreen(
        role: _selectedRole,
        onCancel: _refreshRoles,
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gestión de Roles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedRole = null;
                      _showRoleForm = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Rol'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<RolesBloc, RolesState>(
                listener: (context, state) {
                  if (state is RoleOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is RoleOperationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is RolesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RolesError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is RolesLoaded) {
                    if (state.roles.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No se encontraron roles.'),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _refreshRoles,
                              child: const Text('Volver a intentar'),
                            )
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.roles.length,
                      itemBuilder: (context, index) {
                        final role = state.roles[index];
                        final permissions = (role['permissions'] as List? ?? [])
                            .map((p) => p['name'].toString())
                            .toList();

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                                      child: Text(
                                        (role['name'] ?? 'R')[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Color(0xFF9C27B0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            role['name'] ?? 'Sin nombre',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            'ID: ${role['id']} | ${permissions.length} permisos',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          setState(() {
                                            _selectedRole = role;
                                            _showRoleForm = true;
                                          });
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Eliminar rol'),
                                              content: const Text('¿Estás seguro de que deseas eliminar este rol? Esta acción no se puede deshacer.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            context.read<RolesBloc>().add(DeleteRole(role['id']));
                                          }
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                        const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                                      ],
                                    ),
                                  ],
                                ),
                                if (permissions.isNotEmpty) ...[
                                  const Divider(height: 24),
                                  Text('Permisos:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 4.0,
                                    children: permissions.take(10).map((p) => Chip(
                                      label: Text(p, style: const TextStyle(fontSize: 11)),
                                      backgroundColor: Colors.grey[200],
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    )).toList(),
                                  ),
                                  if (permissions.length > 10)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text('+${permissions.length - 10} más...', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
                                    )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No hay datos'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 