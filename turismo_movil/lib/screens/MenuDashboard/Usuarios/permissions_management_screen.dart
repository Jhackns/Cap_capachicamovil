import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/permissions/permissions_bloc.dart';
import '../../../blocs/permissions/permissions_event.dart';
import '../../../blocs/permissions/permissions_state.dart';

class PermissionsManagementScreen extends StatefulWidget {
  const PermissionsManagementScreen({Key? key}) : super(key: key);

  @override
  State<PermissionsManagementScreen> createState() => _PermissionsManagementScreenState();
}

class _PermissionsManagementScreenState extends State<PermissionsManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PermissionsBloc>().add(LoadPermissions());
  }

  @override
  Widget build(BuildContext context) {
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
                  'Permisos del Sistema',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Los permisos son las acciones específicas que los usuarios pueden realizar en el sistema. Estos permisos se asignan a roles, y los roles se asignan a usuarios.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar permisos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                context.read<PermissionsBloc>().add(FilterPermissions(searchQuery: value));
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<PermissionsBloc, PermissionsState>(
                builder: (context, state) {
                  if (state is PermissionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PermissionsError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is PermissionsLoaded) {
                    if (state.filteredGroupedPermissions.isEmpty) {
                      return const Center(child: Text('No se encontraron permisos.'));
                    }
                    return ListView(
                      children: state.filteredGroupedPermissions.entries.map((entry) {
                        final group = entry.key;
                        final perms = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        group,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9C27B0).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${perms.length} permisos',
                                        style: const TextStyle(
                                          color: Color(0xFF9C27B0),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...perms.map((p) => ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.lock_outline, color: Color(0xFF9C27B0), size: 20),
                                      title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                                      subtitle: Text('ID: ${p['id']}', style: const TextStyle(fontSize: 12)),
                                    )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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