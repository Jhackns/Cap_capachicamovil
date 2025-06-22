import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/alojamiento_bloc/alojamiento_bloc.dart';
// import '../../models/alojamiento/alojamiento_model.dart';
// import '../../models/alojamiento/foto_alojamiento_model.dart'; // For photo gallery

class AlojamientoDetailScreen extends StatelessWidget {
  final String alojamientoId;

  const AlojamientoDetailScreen({super.key, required this.alojamientoId});

  @override
  Widget build(BuildContext context) {
    // In a real app, fetch details when screen loads, if not already passed in
    // BlocProvider.of<AlojamientoBloc>(context).add(LoadAlojamientoDetails(alojamientoId: alojamientoId));

    // Placeholder data for an Alojamiento
    final mockAlojamiento = {
      'id': alojamientoId,
      'nombre': 'Cabaña del Sol (Detalle)',
      'descripcion': 'Una descripción muy detallada de la Cabaña del Sol, perfecta para tus vacaciones en Capachica. Disfruta de vistas panorámicas al lago Titicaca, amaneceres espectaculares y la tranquilidad de la naturaleza. La cabaña cuenta con todas las comodidades modernas manteniendo un estilo rústico y acogedor.',
      'precioPorNoche': 150.0,
      'anfitrion': {'nombre': 'Juan Perez', 'avatarUrl': 'https://via.placeholder.com/50x50.png?text=Host'},
      'direccion': {'fullAddress': 'Principal S/N, Capachica, Puno, Perú', 'latitud': -15.65, 'longitud': -69.83},
      'fotos': [
        {'urlFoto': 'https://via.placeholder.com/400x250.png?text=Detalle+1'},
        {'urlFoto': 'https://via.placeholder.com/400x250.png?text=Detalle+2'},
        {'urlFoto': 'https://via.placeholder.com/400x250.png?text=Detalle+3'},
      ],
      'servicios': ['Wifi', 'Desayuno incluido', 'Cocina equipada', 'Estacionamiento gratuito'],
      'calificacionPromedio': 4.7,
      'numeroDeResenas': 32,
      'disponibilidad': 'Consultar disponibilidad', // Placeholder
    };

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // appBar: AppBar(title: Text(mockAlojamiento['nombre'] as String)),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(mockAlojamiento['nombre'] as String, style: TextStyle(shadows: [Shadow(blurRadius: 2.0)])),
              background: PageView.builder(
                itemCount: (mockAlojamiento['fotos'] as List).length,
                itemBuilder: (context, index) {
                  return Image.network(
                    (mockAlojamiento['fotos'] as List)[index]['urlFoto'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  );
                },
              ),
            ),
            actions: [
              IconButton(icon: Icon(Icons.favorite_border), onPressed: () { /* Add to favorites */ })
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mockAlojamiento['nombre'] as String, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text('${mockAlojamiento['calificacionPromedio']} (${mockAlojamiento['numeroDeResenas']} reseñas)', style: textTheme.bodyLarge),
                        const SizedBox(width: 8),
                        Text('·', style: textTheme.bodyLarge),
                        const SizedBox(width: 8),
                        Text(
                          (mockAlojamiento['direccion'] as Map<String, dynamic>?)?['fullAddress'].toString().split(',')[1].trim() ?? 'Unknown City',
                          style: textTheme.bodyLarge?.copyWith(decoration: TextDecoration.underline),
                        ), // City
                      ],
                    ),
                    const Divider(height: 32),
                    // Host Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage((mockAlojamiento['anfitrion'] as Map)['avatarUrl'] as String),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alojado por ${(mockAlojamiento['anfitrion'] as Map)['nombre']}', style: textTheme.titleMedium),
                            Text('Superanfitrión · 3 años de experiencia', style: textTheme.bodySmall), // Placeholder
                          ],
                        )
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Descripción', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(mockAlojamiento['descripcion'] as String, style: textTheme.bodyMedium),
                    const Divider(height: 32),
                    Text('Servicios ofrecidos', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: (mockAlojamiento['servicios'] as List<String>).map((servicio) => Chip(label: Text(servicio))).toList(),
                    ),
                    const Divider(height: 32),
                    Text('Ubicación', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      (mockAlojamiento['direccion'] as Map<String, dynamic>?)?['fullAddress'] ?? 'Dirección no disponible',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Container( // Placeholder for Map
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: Text('Google Maps Placeholder')),
                    ),
                    const Divider(height: 32),
                    Text('Disponibilidad', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(mockAlojamiento['disponibilidad'] as String, style: textTheme.bodyMedium),
                    // Placeholder for calendar view or date picker
                    ElevatedButton(onPressed: () {}, child: Text('Consultar Fechas')),

                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\$${(mockAlojamiento['precioPorNoche'] as double).toStringAsFixed(2)} PEN', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('por noche', style: textTheme.bodySmall),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to booking flow or show booking dialog
                  print('Book Now pressed for ${mockAlojamiento['nombre']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Placeholder for Booking Flow')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                child: const Text('Reservar', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}