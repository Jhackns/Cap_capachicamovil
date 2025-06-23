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
        imgUrl = '';
      } else {
        imgUrl = 'https://via.placeholder.com/400x300?text=No+disponible';
      }
    } else {
      imgUrl = 'https://via.placeholder.com/400x300?text=No+disponible';
    }
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imgUrl.isNotEmpty
              ? SizedBox(
                  width: 56,
                  height: 56,
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 32),
                    ),
                  ),
                )
              : Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 32, color: Colors.grey),
                ),
        ),
        title: Text(
          entrepreneur.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entrepreneur.tipoServicio,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (entrepreneur.location.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 2),
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
            Text(
              entrepreneur.description ?? 'Sin descripción',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showEditButton)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: onEdit,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (showDeleteButton)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: onDelete,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
