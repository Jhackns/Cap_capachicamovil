import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/alojamiento_bloc/alojamiento_bloc.dart';
// import '../../models/alojamiento/alojamiento_model.dart';
// import './alojamiento_detail_screen.dart'; // For navigation
// import '../../widgets/alojamiento_card/alojamiento_card.dart'; // A custom widget for displaying items

class AlojamientoListScreen extends StatelessWidget {
  const AlojamientoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would BlocProvider the AlojamientoBloc higher up the widget tree
    // and use BlocBuilder here.
    // For now, let's assume we have a mock list of alojamientos.

    // final mockAlojamientos = (context.watch<AlojamientoBloc>().state as AlojamientosLoaded).alojamientos;
    // This is how you might access it if bloc was setup and in loaded state.
    // For placeholder:
    final mockAlojamientos = [
      {'id': 'alo1', 'nombre': 'Cabaña del Sol', 'precioPorNoche': 150.0, 'urlFoto': 'https://via.placeholder.com/150x100.png?text=Cabaña+Sol'},
      {'id': 'alo2', 'nombre': 'Casa Rural Pacha Mama', 'precioPorNoche': 120.0, 'urlFoto': 'https://via.placeholder.com/150x100.png?text=Casa+Pacha'},
      {'id': 'alo3', 'nombre': 'Hospedaje Inti Wasi', 'precioPorNoche': 100.0, 'urlFoto': 'https://via.placeholder.com/150x100.png?text=Inti+Wasi'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alojamientos en Capachica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Placeholder for filter dialog/screen
              print('Filter button pressed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Placeholder for Filters')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Placeholder for search functionality
              print('Search button pressed');
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Placeholder for Search')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Placeholder for filter display or sorting options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(icon: Icon(Icons.sort), label: Text('Ordenar'), onPressed: () {}),
                ElevatedButton.icon(icon: Icon(Icons.map), label: Text('Mapa'), onPressed: () {}),
              ],
            ),
          ),
          Expanded(
            // child: BlocBuilder<AlojamientoBloc, AlojamientoState>(
            //   builder: (context, state) {
            //     if (state is AlojamientosLoading) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (state is AlojamientosLoaded) {
            //       if (state.alojamientos.isEmpty) {
            //         return const Center(child: Text('No hay alojamientos disponibles.'));
            //       }
            //       return ListView.builder(
            //         itemCount: state.alojamientos.length,
            //         itemBuilder: (context, index) {
            //           final alojamiento = state.alojamientos[index];
            //           // return AlojamientoCard(alojamiento: alojamiento); // Using a custom widget
            //           return Card( // Simple card for now
            //             margin: const EdgeInsets.all(8.0),
            //             child: ListTile(
            //               leading: Image.network(alojamiento.fotos.isNotEmpty ? alojamiento.fotos.first.urlFoto : 'https://via.placeholder.com/100x100.png?text=No+Image' , width: 100, fit: BoxFit.cover),
            //               title: Text(alojamiento.nombre),
            //               subtitle: Text('\$${alojamiento.precioPorNoche.toStringAsFixed(2)} por noche\n${alojamiento.direccion.ciudad}'),
            //               isThreeLine: true,
            //               onTap: () {
            //                 // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlojamientoDetailScreen(alojamientoId: alojamiento.id)));
            //                 print('Tapped on ${alojamiento.nombre}');
            //               },
            //             ),
            //           );
            //         },
            //       );
            //     } else if (state is AlojamientosError) {
            //       return Center(child: Text('Error: ${state.message}'));
            //     }
            //     return const Center(child: Text('Presiona el botón para cargar alojamientos.')); // Initial or unknown state
            //   },
            // ),
            // Placeholder ListView:
            child: ListView.builder(
              itemCount: mockAlojamientos.length,
              itemBuilder: (context, index) {
                final alojamiento = mockAlojamientos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: InkWell(
                    onTap: () {
                      // Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlojamientoDetailScreen(alojamientoId: alojamiento['id']! as String)));
                      print('Tapped on ${alojamiento['nombre']} (ID: ${alojamiento['id']})');
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Navigate to details for ${alojamiento['nombre']}')),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                          child: Image.network(
                            alojamiento['urlFoto']! as String,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alojamiento['nombre']! as String, style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 4),
                              Text('\$${(alojamiento['precioPorNoche']! as double).toStringAsFixed(2)} por noche', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text('4.5 (25 reseñas)', style: Theme.of(context).textTheme.bodySmall), // Placeholder
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // FloatingActionButton( // Example to trigger load, if not done automatically
      //   onPressed: () {
      //     // BlocProvider.of<AlojamientoBloc>(context).add(LoadAlojamientos());
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
