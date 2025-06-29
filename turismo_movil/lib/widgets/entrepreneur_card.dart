import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/entrepreneur.dart';

class EntrepreneurCard extends StatelessWidget {
  final Entrepreneur entrepreneur;
  final VoidCallback? onTap;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditButton;
  final bool showDeleteButton;
  final bool isGridView;

  const EntrepreneurCard({
    Key? key,
    required this.entrepreneur,
    this.onTap,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
    this.showEditButton = false,
    this.showDeleteButton = true,
    this.isGridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGridView ? _buildGridCard(context) : _buildListCard(context);
  }

  Widget _buildListCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        leading: _buildImage(context, width: 56, height: 56),
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
            _buildCategoryChip(context),
            const SizedBox(height: 4),
            Text(
              entrepreneur.description ?? 'Sin descripción',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: isAdmin ? _buildAdminButtons() : null,
      ),
    );
  }

  Widget _buildGridCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: _buildImage(context, fit: BoxFit.cover),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entrepreneur.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildCategoryChip(context),
                    const Spacer(),
                    if (isAdmin)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: _buildAdminButtons(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
    );
  }

  Widget _buildAdminButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showEditButton)
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.blue.shade700,
            onPressed: onEdit,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Editar',
          ),
        if (showEditButton && showDeleteButton) const SizedBox(width: 8),
        if (showDeleteButton)
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red.shade700,
            onPressed: onDelete,
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Eliminar',
          ),
      ],
    );
  }

  Widget _buildImage(BuildContext context, {double? width, double? height, BoxFit? fit}) {
    String? imageUrl;
    if (entrepreneur.imagenes.isNotEmpty) {
      final firstImage = entrepreneur.imagenes.first;
      if (firstImage.startsWith('http')) {
        imageUrl = firstImage;
      }
    }

    if (imageUrl == null && entrepreneur.imageUrl != null && entrepreneur.imageUrl!.startsWith('http')) {
      imageUrl = entrepreneur.imageUrl!;
    }

    final Widget placeholder = Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
      ),
    );

    return SizedBox(
      width: width,
      height: height,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit ?? BoxFit.contain,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) => placeholder,
            )
          : placeholder,
    );
  }
}
