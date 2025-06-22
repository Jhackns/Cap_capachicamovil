import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/alojamiento_bloc/alojamiento_bloc.dart';

class ManageAlojamientosScreen extends StatelessWidget {
  const ManageAlojamientosScreen({super.key});

  void _addAlojamiento(BuildContext context) {
    // Placeholder for add alojamiento form/dialog
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditAlojamientoScreen()));
    print('Add Alojamiento action');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Placeholder for Add Alojamiento Form')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock list of alojamientos for admin view
    final mockAdminAlojamientos = [
      {'id': 'alo1', 'nombre': 'Cabaña del Sol', 'ciudad': 'Capachica'},
      {'id': 'alo2', 'nombre': 'Casa Rural Pacha Mama', 'ciudad': 'Llachon'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Alojamientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Agregar Alojamiento',
            onPressed: () => _addAlojamiento(context),
          ),
        ],
      ),
      body:
      // BlocBuilder<AlojamientoBloc, AlojamientoState>( // Assuming admin also uses AlojamientoBloc
      //   builder: (context, state) {
      //     if (state is AlojamientosLoading) {
      //       return const Center(child: CircularProgressIndicator());
      //     } else if (state is AlojamientosLoaded) {
      //       if (state.alojamientos.isEmpty) {
      //         return const Center(child: Text('No hay alojamientos para gestionar.'));
      //       }
      //       return ListView.builder(
      //         itemCount: state.alojamientos.length,
      //         itemBuilder: (context, index) {
      //           final alojamiento = state.alojamientos[index];
      //           return ListTile(
      //             title: Text(alojamiento.nombre),
      //             subtitle: Text('\$${alojamiento.direccion.ciudad} - ID: \${alojamiento.id}'),
      //             trailing: Row(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 IconButton(
      //                   icon: const Icon(Icons.edit, color: Colors.blue),
      //                   onPressed: () {
      //                     // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddEditAlojamientoScreen(alojamiento: alojamiento)));
      //                     print('Edit \${alojamiento.id}');
      //                   },
      //                 ),
      //                 IconButton(
      //                   icon: const Icon(Icons.delete, color: Colors.red),
      //                   onPressed: () {
      //                     // Show confirmation dialog then:
      //                     // BlocProvider.of<AlojamientoBloc>(context).add(DeleteAlojamiento(alojamientoId: alojamiento.id));
      //                     print('Delete \${alojamiento.id}');
      //                   },
      //                 ),
      //               ],
      //             ),
      //           );
      //         },
      //       );
      //     } else if (state is AlojamientosError) {
      //       return Center(child: Text('Error: \${state.message}'));
      //     }
      //     return const Center(child: Text('Cargando alojamientos...'));
      //   },
      // )
      // Placeholder list for admin:
      ListView.builder(
        itemCount: mockAdminAlojamientos.length,
        itemBuilder: (context, index) {
          final item = mockAdminAlojamientos[index];
          return ListTile(
            title: Text(item['nombre']!),
            subtitle: Text(item['ciudad']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {
                   print('Edit ${item['id']}');
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Placeholder to Edit ${item['nombre']}')),
                  );
                }),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {
                  print('Delete ${item['id']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Placeholder to Delete ${item['nombre']}')),
                  );
                }),
              ],
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton( // Alternative way to add
      //   onPressed: () => _addAlojamiento(context),
      //   tooltip: 'Agregar Alojamiento',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
