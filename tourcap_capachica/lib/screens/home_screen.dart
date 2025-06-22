import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/theme_switcher.dart';
// Importaciones de widgets

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour Capachica'),
        centerTitle: true,
        actions: [
          // Botón para cambiar entre tema claro y oscuro
          const ThemeSwitcher(),
          const SizedBox(width: 8),
          // Icono de usuario con navegación condicional
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (isLoggedIn) {
                // Si está autenticado, ir al dashboard
                Navigator.pushNamed(context, '/dashboard');
              } else {
                // Si no está autenticado, ir a login
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.background,
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
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl: url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
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
                    elevation: 4,
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Descubre la belleza y cultura de Capachica, una península mágica en el Lago Titicaca. Explora nuestros emprendimientos locales y vive una experiencia única.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.people),
                            label: const Text('Ver Emprendedores'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/entrepreneurs');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Sección de características
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Descubre Capachica',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildFeatureCard(
                            context,
                            icon: Icons.hotel,
                            title: 'Hospedaje',
                            description: 'Encuentra alojamiento con familias locales',
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.restaurant,
                            title: 'Gastronomía',
                            description: 'Prueba platos típicos de la región',
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.landscape,
                            title: 'Turismo',
                            description: 'Visita lugares emblemáticos',
                          ),
                          _buildFeatureCard(
                            context,
                            icon: Icons.shopping_bag,
                            title: 'Artesanía',
                            description: 'Adquiere productos locales',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Botón de inicio de sesión
                
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegar a la sección correspondiente según el ícono
          if (icon == Icons.hotel) {
            Navigator.pushNamed(context, '/hospedaje');
          } else if (icon == Icons.restaurant) {
            Navigator.pushNamed(context, '/gastronomia');
          } else if (icon == Icons.landscape) {
            Navigator.pushNamed(context, '/turismo');
          } else if (icon == Icons.shopping_bag) {
            Navigator.pushNamed(context, '/artesania');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
