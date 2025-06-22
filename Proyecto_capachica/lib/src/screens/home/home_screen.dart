import 'package:flutter/material.dart';
import '../../widgets/alojamiento_card/alojamiento_card.dart';
import '../alojamientos/alojamiento_list_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../reservas/create_reserva_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reemplaza esta sección en tu HomeScreen
    final alojamientos = [
      {
        'id': '1',
        'nombre': 'Cabaña del Sol',
        // URLs reales de Unsplash que funcionan
        'urlFoto': 'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=300&h=180&fit=crop&crop=center',
        'precioPorNoche': 150.0,
        'ciudad': 'Capachica',
        'calificacionPromedio': 4.7,
        'numeroDeResenas': 32,
      },
      {
        'id': '2',
        'nombre': 'Casa del Lago',
        'urlFoto': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=300&h=180&fit=crop&crop=center',
        'precioPorNoche': 120.0,
        'ciudad': 'Puno',
        'calificacionPromedio': 4.5,
        'numeroDeResenas': 25,
      },
      {
        'id': '3',
        'nombre': 'Hotel Titicaca',
        'urlFoto': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=300&h=180&fit=crop&crop=center',
        'precioPorNoche': 200.0,
        'ciudad': 'Capachica',
        'calificacionPromedio': 4.9,
        'numeroDeResenas': 48,
      },
      {
        'id': '4',
        'nombre': 'Cabaña Vista Panorámica',
        'urlFoto': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=300&h=180&fit=crop&crop=center',
        'precioPorNoche': 180.0,
        'ciudad': 'Capachica',
        'calificacionPromedio': 4.6,
        'numeroDeResenas': 38,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar con degradado
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            actions: [
              // Botón de perfil/login
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1976D2), // Azul profundo
                      Color(0xFF42A5F5), // Azul claro
                    ],
                  ),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Descubre los mejores alojamientos en Capachica',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Turismo Capachica',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Contenido principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barra de búsqueda
                  _buildSearchBar(context),

                  const SizedBox(height: 24),

                  // Sección de estadísticas rápidas
                  _buildStatsSection(),

                  const SizedBox(height: 30),

                  // Botones de exploración
                  _buildQuickActionsSection(context, alojamientos),

                  const SizedBox(height: 30),

                  // Título de alojamientos destacados
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber[600],
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Alojamientos Destacados',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 3,
                    width: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lista de alojamientos
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final alojamiento = alojamientos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AlojamientoCard(alojamientoData: alojamiento),
                  );
                },
                childCount: alojamientos.length,
              ),
            ),
          ),

          // Espaciado final
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      // Botón flotante para reservas rápidas
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(
          context,
          '/reservas/create',
          arguments: alojamientos[0],
        ),
        backgroundColor: const Color(0xFF1976D2),
        icon: const Icon(Icons.add),
        label: const Text('Reservar'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: '¿A dónde quieres ir?',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white, size: 20),
              onPressed: () {
                // Abrir filtros
              },
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () {
          // Navegar a pantalla de búsqueda
          Navigator.pushNamed(context, '/search');
        },
        readOnly: true,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.home_work,
            value: '15+',
            label: 'Alojamientos',
            color: const Color(0xFF4CAF50),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: Icons.people,
            value: '500+',
            label: 'Huéspedes',
            color: const Color(0xFF2196F3),
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            icon: Icons.star,
            value: '4.8',
            label: 'Calificación',
            color: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, List<Map<String, dynamic>> alojamientos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explora Capachica',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),
        // SOLUCIÓN: Usar LayoutBuilder para calcular el ancho disponible
        LayoutBuilder(
          builder: (context, constraints) {
            // Calcular el ancho disponible para cada tarjeta
            double availableWidth = constraints.maxWidth;
            double cardWidth = (availableWidth - 12) / 2; // 12 = spacing entre tarjetas

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, // Reducido de 16 a 12
              mainAxisSpacing: 12,   // Reducido de 16 a 12
              childAspectRatio: 1.4, // Reducido de 1.5 a 1.4
              children: [
                _buildActionCard(
                  context: context,
                  title: 'Cabañas',
                  subtitle: 'Vista al lago',
                  icon: Icons.cabin,
                  color: const Color(0xFF4CAF50),
                  onTap: () => Navigator.pushNamed(context, '/alojamientos'),
                ),
                _buildActionCard(
                  context: context,
                  title: 'Hoteles',
                  subtitle: 'Comodidad',
                  icon: Icons.hotel,
                  color: const Color(0xFF2196F3),
                  onTap: () => Navigator.pushNamed(context, '/alojamientos'),
                ),
                _buildActionCard(
                  context: context,
                  title: 'Experiencias',
                  subtitle: 'Tours locales',
                  icon: Icons.explore,
                  color: const Color(0xFFFF9800),
                  onTap: () => Navigator.pushNamed(context, '/experiencias'),
                ),
                _buildActionCard(
                  context: context,
                  title: 'Favoritos',
                  subtitle: 'Mis guardados',
                  icon: Icons.favorite,
                  color: const Color(0xFFE91E63),
                  onTap: () => Navigator.pushNamed(context, '/favoritos'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}