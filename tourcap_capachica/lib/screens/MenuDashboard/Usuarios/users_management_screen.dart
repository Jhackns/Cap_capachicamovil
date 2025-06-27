import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../blocs/users/users_bloc.dart';
import '../../../blocs/users/users_event.dart';
import '../../../blocs/users/users_state.dart';
import 'user_form_screen.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({Key? key}) : super(key: key);

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  String _selectedRole = 'Todos';
  bool _showUserForm = false;
  Map<String, dynamic>? _selectedUser;

  final List<String> _statusOptions = ['Todos', 'Activos', 'Inactivos'];
  final List<String> _roleOptions = [
    'Todos',
    'admin',
    'user',
    'emprendedor',
    'moderador',
  ];

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadUsers());
  }

  void _applyFilters() {
    context.read<UsersBloc>().add(FilterUsers(
      searchQuery: _searchQuery,
      status: _selectedStatus,
      role: _selectedRole,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_showUserForm) {
      return UserFormScreen(
        user: _selectedUser,
        onCancel: () {
          setState(() {
            _showUserForm = false;
            _selectedUser = null;
          });
          context.read<UsersBloc>().add(LoadUsers());
        },
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
                  'Gestión de Usuarios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedUser = null;
                      _showUserForm = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo Usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C27B0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Filtros de búsqueda
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            items: _statusOptions
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedStatus = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: _roleOptions
                                .map((role) => DropdownMenuItem(
                                      value: role,
                                      child: Text(role[0].toUpperCase() + role.substring(1)),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedRole = value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.filter_alt_rounded),
                        label: const Text('Filtrar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<UsersBloc, UsersState>(
                listener: (context, state) {
                  if (state is UserOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is UserOperationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UsersError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is UsersLoaded) {
                    if (state.filteredUsers.isEmpty) {
                      return const Center(child: Text('No se encontraron usuarios'));
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        itemCount: state.filteredUsers.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = state.filteredUsers[index];
                          final roles = (user['roles'] as List? ?? [])
                              .map((r) {
                                if (r is Map && r.containsKey('name')) return r['name'].toString();
                                return r.toString();
                              })
                              .toList();
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getUserRoleColor(
                                roles.isNotEmpty ? roles.first : '',
                              ),
                              backgroundImage: user['foto_perfil'] != null
                                  ? NetworkImage(user['foto_perfil'])
                                  : null,
                              child: user['foto_perfil'] == null
                                  ? Text(
                                      (user['name'] ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              user['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? ''),
                                if (user['phone'] != null && user['phone'].toString().isNotEmpty)
                                  Text(
                                    user['phone'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                if (roles.isNotEmpty)
                                  Wrap(
                                    spacing: 4,
                                    children: roles
                                        .map<Widget>((role) => Chip(
                                              label: Text(
                                                role,
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                              backgroundColor: const Color(0xFF9C27B0).withOpacity(0.1),
                                              labelStyle: const TextStyle(color: Color(0xFF9C27B0)),
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ))
                                        .toList(),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getUserStatusColor(
                                      user['active'] == true ? 'active' : 'inactive',
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user['active'] == true ? 'Activo' : 'Inactivo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    setState(() {
                                      _selectedUser = user;
                                      _showUserForm = true;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Eliminar',
                                  onPressed: () => _showDeleteDialog(user),
                                ),
                                IconButton(
                                  icon: Icon(
                                    user['active'] == true ? Icons.block : Icons.check_circle,
                                    color: user['active'] == true ? Colors.orange : Colors.green,
                                  ),
                                  tooltip: user['active'] == true ? 'Desactivar' : 'Activar',
                                  onPressed: () => _showActivateDialog(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.lock, color: Color(0xFF9C27B0)),
                                  tooltip: 'Permisos',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

  void _showDeleteDialog(Map<String, dynamic> user) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: const Text('¿Estás seguro de que deseas eliminar este usuario? Esta acción no se puede deshacer.'),
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
    ).then((confirm) {
      if (confirm == true) {
        context.read<UsersBloc>().add(DeleteUser(user['id']));
      }
    });
  }

  void _showActivateDialog(Map<String, dynamic> user) {
    final isActive = user['active'] == true;
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isActive ? 'Desactivar usuario' : 'Activar usuario'),
        content: Text(isActive
            ? '¿Estás seguro de que deseas desactivar este usuario?'
            : '¿Estás seguro de que deseas activar este usuario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.orange : Colors.green,
            ),
            child: Text(isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    ).then((confirm) {
      if (confirm == true) {
        if (isActive) {
          context.read<UsersBloc>().add(DeactivateUser(user['id']));
        } else {
          context.read<UsersBloc>().add(ActivateUser(user['id']));
        }
      }
    });
  }

  Color _getUserRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'emprendedor':
        return Colors.green;
      case 'moderador':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getUserStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 