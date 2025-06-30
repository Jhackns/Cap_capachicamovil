import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../widgets/theme_switcher.dart';
// Importaciones de widgets

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  final LatLng _capachicaLatLng = const LatLng(-15.6927, -69.8194);

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionUsuario();
  }

  Future<void> _obtenerUbicacionUsuario() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    try {
      final userLocation = await location.getLocation();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
        });
      }
    } catch (e) {
      // Si no se puede obtener la ubicación, usar la ubicación de Capachica
      if (mounted) {
        setState(() {
          _userLocation = _capachicaLatLng;
        });
      }
    }
  }

  void _centrarEnUbicacion() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    // Imágenes de ejemplo para el carrusel
    final List<String> imageUrls = [
      'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg',
      'https://www.titicaca-peru.com/img/peni_capachica1.jpg',
      'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1',
    ];

    // Imágenes para la sección Momentos
    final List<String> momentosImages = [
      'https://www.titicaca-peru.com/img/peni_capachica1.jpg',
      'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg',
      'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1',
      'https://www.titicaca-peru.com/img/peni_capachica1.jpg',
    ];

    // Imágenes para las comunidades
    final List<Map<String, String>> comunidades = [
      {'nombre': 'Llachón', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
      {'nombre': 'Cotos', 'imagen': 'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg'},
      {'nombre': 'Siale', 'imagen': 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1'},
      {'nombre': 'Hilata', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
      {'nombre': 'Isañura', 'imagen': 'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg'},
      {'nombre': 'San Cristóbal', 'imagen': 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1'},
      {'nombre': 'Escallani', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
      {'nombre': 'Chillora', 'imagen': 'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg'},
      {'nombre': 'Yapura', 'imagen': 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1'},
      {'nombre': 'Collasuyo', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
      {'nombre': 'Miraflores', 'imagen': 'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg'},
      {'nombre': 'Villa Lago', 'imagen': 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1'},
      {'nombre': 'Capano', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
      {'nombre': 'Ccotos', 'imagen': 'https://img.freepik.com/fotos-premium/vista-sobre-paisaje-lago-titicaca_653449-9944.jpg'},
      {'nombre': 'Yancaco', 'imagen': 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/17/ce/73/23/island-amantani.jpg?w=400&h=300&s=1'},
      {'nombre': 'Capachica Central', 'imagen': 'https://www.titicaca-peru.com/img/peni_capachica1.jpg'},
    ];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementar chatbot en el futuro
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionalidad de chat próximamente disponible'),
              backgroundColor: Colors.blue,
            ),
          );
        },
        icon: const Icon(Icons.chat),
        label: const Text('Chat'),
        backgroundColor: const Color(0xFF9C27B0),
        heroTag: 'home_chat_fab',
      ),
      appBar: AppBar(
        title: const Text(
          'Tour Capachica',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1B9A),
        actions: [
          const ThemeSwitcher(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
              if (isLoggedIn) {
                Navigator.pushNamed(context, '/dashboard');
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF9C27B0),
              Color(0xFFE1BEE7),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Carrusel de imágenes
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: CarouselSlider(
                    items: imageUrls.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                                memCacheWidth: (MediaQuery.of(context).size.width * 0.8).toInt(),
                                memCacheHeight: 200,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 200,
                      aspectRatio: 16/9,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ),
                
                // Sección de bienvenida
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Bienvenido a Capachica!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Un paraíso donde la naturaleza, cultura y tradición se fusionan en una experiencia única e inolvidable.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.explore),
                            label: const Text('Ir a Explorar!'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              // Navegar a la pestaña Explorar
                              Navigator.pushNamed(context, '/explore');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Sección Momentos
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Momentos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: momentosImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: momentosImages[index],
                                width: 160,
                                height: 120,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 160,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 160,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sección Historia
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Capachica es una península situada en el lago Titicaca con una rica historia preinca e inca. Durante la colonia española, se establecieron haciendas que luego dieron paso a comunidades campesinas que hoy preservan su cultura y patrimonio. Las familias de Capachica han mantenido sus tradiciones ancestrales por generaciones, dedicándose principalmente a la agricultura, pesca y ahora al turismo vivencial.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sección Comunidades
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comunidades',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: comunidades.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: comunidades[index]['imagen']!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    comunidades[index]['nombre']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sección Localización
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Localización',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _capachicaLatLng,
                                    initialZoom: 12,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                      'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ3JpbWFsZG9hcnJlZG9uZG8iLCJhIjoiY21hYmJvMGpoMmF6YjJrb29tNnJ0MXQ1dyJ9.Em9vVlsuF3-ddqRnxTMYAw',
                                      userAgentPackageName: 'com.example.turismo_capachica',
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        // Marcador de Capachica
                                        Marker(
                                          point: const LatLng(-15.6927, -69.8194),
                                          width: 40,
                                          height: 40,
                                          child: Icon(
                                            Icons.location_pin,
                                            size: 40,
                                            color: Color(0xFF9C27B0),
                                          ),
                                        ),
                                        // Marcador de ubicación del usuario
                                        if (_userLocation != null)
                                          Marker(
                                            point: _userLocation!,
                                            width: 40,
                                            height: 40,
                                            child: Icon(
                                              Icons.person_pin_circle,
                                              size: 40,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        // Marcadores de comunidades principales
                                        Marker(
                                          point: const LatLng(-15.6850, -69.8250),
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.home,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Marker(
                                          point: const LatLng(-15.7000, -69.8100),
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.home,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Marker(
                                          point: const LatLng(-15.6800, -69.8300),
                                          width: 30,
                                          height: 30,
                                          child: Icon(
                                            Icons.home,
                                            size: 30,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Botón para centrar en ubicación
                                Positioned(
                                  bottom: 16,
                                  right: 16,
                                  child: FloatingActionButton(
                                    onPressed: _centrarEnUbicacion,
                                    backgroundColor: const Color(0xFF9C27B0),
                                    foregroundColor: Colors.white,
                                    mini: true,
                                    child: const Icon(Icons.my_location),
                                  ),
                                ),
                                // Leyenda del mapa
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Leyenda',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.location_pin, size: 16, color: Color(0xFF9C27B0)),
                                            const SizedBox(width: 4),
                                            const Text('Capachica', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.person_pin_circle, size: 16, color: Colors.blue),
                                            const SizedBox(width: 4),
                                            const Text('Tu ubicación', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.home, size: 16, color: Colors.green),
                                            const SizedBox(width: 4),
                                            const Text('Comunidades', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
