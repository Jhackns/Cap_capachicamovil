import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../widgets/theme_switcher.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    final isDark = themeProvider.themeMode == ThemeMode.dark;

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
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      extendBody: true, // Permite que el cuerpo se extienda debajo del FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF385C), Color(0xFFE61E4D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF385C).withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Ya no se muestra el SnackBar con "..."
            Navigator.pushNamed(context, '/support');
          },
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
          label: const Text(
            'Chat',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          heroTag: 'home_chat_fab',
        ),
      ),
      appBar: AppBar(
        title: Text(
          'Tour Capachica',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF484848),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF2F2F2F) : const Color(0xFFDDDDDD),
                width: 1,
              ),
            ),
            child: const ThemeSwitcher(),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF2F2F2F) : const Color(0xFFDDDDDD),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.person_outline,
                color: isDark ? Colors.white : const Color(0xFF484848),
                size: 20,
              ),
              onPressed: () {
                final isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
                if (isLoggedIn) {
                  Navigator.pushNamed(context, '/dashboard');
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCarousel(imageUrls, context, isDark),
                _buildWelcomeSection(context, isDark),
                _buildMomentsSection(momentosImages, context, isDark),
                _buildHistorySection(context, isDark),
                _buildCommunitiesCarousel(comunidades, context, isDark),
                _buildLocationSectionWithMap(context, isDark),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCarousel(List<String> imageUrls, BuildContext context, bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.38, // Reducido de 0.4 para dar más espacio
      margin: const EdgeInsets.only(bottom: 8), // Reducido de 16
      child: CarouselSlider(
        items: imageUrls.map((url) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFFF7F7F7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF385C)),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFFF7F7F7),
                      child: const Icon(Icons.error, color: Color(0xFFB0B0B0)),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8, // Reducido de 16
                  left: 8, // Reducido de 16
                  right: 8, // Reducido de 16
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descubre Capachica',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Reducido de 24
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Experiencias únicas en el lago Titicaca',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12, // Reducido de 14
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.38,
          aspectRatio: 16 / 9,
          viewportFraction: 1.0,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayAnimationDuration: const Duration(milliseconds: 1200),
          autoPlayCurve: Curves.easeInOut,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Reducido de 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
            child: Text(
              '¡Bienvenido a Capachica!',
              style: TextStyle(
                fontSize: 20, // Reducido de 22
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 4), // Reducido de 8
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
            child: Text(
              'Un paraíso donde la naturaleza, cultura y tradición se fusionan en una experiencia única e inolvidable.',
              style: TextStyle(
                fontSize: 12, // Reducido de 14
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF717171),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8), // Reducido de 16
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
            child: SizedBox(
              width: double.infinity,
              height: 40, // Reducido de 48
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/explore');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF385C),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ir a Explorar',
                  style: TextStyle(
                    fontSize: 14, // Reducido de 16
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentsSection(List<String> momentosImages, BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Reducido de 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
            child: Text(
              'Momentos especiales',
              style: TextStyle(
                fontSize: 18, // Reducido de 20
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 8), // Reducido de 12
          SizedBox(
            height: 160, // Reducido de 180
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
              itemCount: momentosImages.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8), // Reducido de 12
              itemBuilder: (context, index) {
                return Container(
                  width: 240, // Reducido de 260
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 8, // Reducido de 10
                        offset: const Offset(0, 2), // Reducido de 3
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: momentosImages[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: const Color(0xFFF7F7F7),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF385C)),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: const Color(0xFFF7F7F7),
                        child: const Icon(Icons.error, color: Color(0xFFB0B0B0)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reducido de 16 y 8
      child: Container(
        padding: const EdgeInsets.all(12), // Reducido de 16
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nuestra Historia',
              style: TextStyle(
                fontSize: 18, // Reducido de 20
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8), // Reducido de 12
            Text(
              'Capachica es una península situada en el lago Titicaca con una rica historia preinca e inca. Durante la colonia española, se establecieron haciendas que luego dieron paso a comunidades campesinas que hoy preservan su cultura y patrimonio.',
              style: TextStyle(
                fontSize: 12, // Reducido de 14
                fontWeight: FontWeight.w400,
                color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF717171),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitiesCarousel(List<Map<String, String>> comunidades, BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8), // Reducido de 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
            child: Text(
              'Comunidades locales',
              style: TextStyle(
                fontSize: 18, // Reducido de 20
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
          ),
          const SizedBox(height: 8), // Reducido de 12
          SizedBox(
            height: 240, // Reducido de 260
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8), // Reducido de 16
              itemCount: comunidades.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8), // Reducido de 12
              itemBuilder: (context, index) {
                return Container(
                  width: 180, // Reducido de 200
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                        spreadRadius: 0,
                        blurRadius: 8, // Reducido de 10
                        offset: const Offset(0, 2), // Reducido de 3
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: comunidades[index]['imagen']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF7F7F7),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF385C)),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF7F7F7),
                              child: const Icon(Icons.error, color: Color(0xFFB0B0B0)),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8), // Reducido de 12
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                comunidades[index]['nombre']!,
                                style: TextStyle(
                                  fontSize: 14, // Reducido de 15
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : const Color(0xFF222222),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Comunidad tradicional',
                                style: TextStyle(
                                  fontSize: 12, // Reducido de 13
                                  fontWeight: FontWeight.w400,
                                  color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF717171),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSectionWithMap(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localización',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark ? const Color(0xFF1F1F1F) : Colors.grey[200],
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
    );
  }
}