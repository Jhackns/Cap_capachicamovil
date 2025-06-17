import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/entrepreneur.dart';

class EntrepreneurCard extends StatelessWidget {
  final Entrepreneur entrepreneur;
  final VoidCallback? onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntrepreneurCard({
    Key? key,
    required this.entrepreneur,
    this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: entrepreneur.imageUrl ?? 'https://via.placeholder.com/400x300?text=No+disponible',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 40),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrepreneur.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      entrepreneur.tipoServicio,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entrepreneur.description ?? 'Sin descripción',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entrepreneur.location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          entrepreneur.location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                  if (isAdmin) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
