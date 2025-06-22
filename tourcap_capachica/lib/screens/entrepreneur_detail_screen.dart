import 'package:flutter/material.dart';
import '../models/entrepreneur.dart';
import '../models/review.dart';
import '../widgets/reviews_section.dart';

class EntrepreneurDetailScreen extends StatelessWidget {
  final Entrepreneur entrepreneur;

  const EntrepreneurDetailScreen({
    Key? key,
    required this.entrepreneur,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para las reseñas
    final reviews = Review.getDummyReviews();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                entrepreneur.imageUrl ?? 'https://via.placeholder.com/400x200',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrepreneur.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entrepreneur.description ?? 'Sin descripción',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, entrepreneur.location ?? 'No especificada'),
                  _buildInfoRow(Icons.phone, entrepreneur.contactInfo ?? 'No especificado'),
                  _buildInfoRow(Icons.email, entrepreneur.email ?? 'No especificado'),
                  _buildInfoRow(Icons.access_time, entrepreneur.horarioAtencion ?? 'No especificado'),
                  _buildInfoRow(Icons.attach_money, entrepreneur.precioRango ?? 'No especificado'),
                  _buildInfoRow(Icons.category, entrepreneur.categoria ?? 'No especificada'),
                  const SizedBox(height: 24),
                  // Agregar la sección de reseñas
                  ReviewsSection(reviews: reviews),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
} 