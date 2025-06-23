import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/entrepreneur.dart';

class EntrepreneurCard extends StatelessWidget {
  final Entrepreneur entrepreneur;
  final VoidCallback? onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditButton; // Controla si se muestra el botón de edición
  final bool showDeleteButton; // Controla si se muestra el botón de eliminar

  const EntrepreneurCard({
    Key? key,
    required this.entrepreneur,
    this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.showEditButton = false, // Por defecto no mostrar el botón de edición
    this.showDeleteButton = true, // Por defecto mostrar el botón de eliminar (para el panel de administración)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Seleccionar la imagen a mostrar
    String imgUrl = '';
    if (entrepreneur.imageUrl != null && entrepreneur.imageUrl!.isNotEmpty && !entrepreneur.imageUrl!.startsWith('[')) {
      imgUrl = entrepreneur.imageUrl!;
    } else if (entrepreneur.imagenes.isNotEmpty && entrepreneur.imagenes[0].isNotEmpty) {
      final img = entrepreneur.imagenes[0];
      if (img.startsWith('http')) {
        imgUrl = img;
      } else if (img.startsWith('assets/')) {
        // Para assets locales
        imgUrl = '';
      } else {
        // Si es solo el nombre del archivo, puedes ajustar aquí la URL base si es necesario
        imgUrl = 'https://via.placeholder.com/400x300?text=No+disponible';
      }
    } else {
      imgUrl = 'https://via.placeholder.com/400x300?text=No+disponible';
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imgUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imgUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 140,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error, size: 40),
                      ),
                    )
                  : Container(
                      height: 140,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entrepreneur.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entrepreneur.description ?? 'Sin descripción',
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entrepreneur.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entrepreneur.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isAdmin) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showEditButton)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: onEdit,
                          ),
                        if (showDeleteButton)
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
