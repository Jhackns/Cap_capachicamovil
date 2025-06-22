import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/resena_bloc/resena_bloc.dart';
// import '../../models/reserva/resena_model.dart';

class ResenaListWidget extends StatelessWidget {
  final String alojamientoId;
  // final List<Resena> resenas; // Pass if already loaded, or load via Bloc

  const ResenaListWidget({super.key, required this.alojamientoId /*, required this.resenas */});

  Widget _buildStarRating(double rating, {double size = 18.0}) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.amber, size: size));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.amber, size: size));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd use BlocBuilder to listen to ResenaBloc state.
    // BlocProvider.of<ResenaBloc>(context).add(LoadResenasForAlojamiento(alojamientoId: alojamientoId));

    // Mock data for reviews
    final mockResenas = [
      {'id': 'rev1', 'nombreUsuario': 'Ana P.', 'fotoUsuarioUrl': 'https://via.placeholder.com/40?text=AP', 'calificacion': 5.0, 'comentario': '¡Lugar mágico! El amanecer sobre el lago es inolvidable. La hospitalidad de la familia fue excepcional.', 'fechaResena': '2024-03-15'},
      {'id': 'rev2', 'nombreUsuario': 'Luis G.', 'fotoUsuarioUrl': 'https://via.placeholder.com/40?text=LG', 'calificacion': 4.0, 'comentario': 'Bonita experiencia, muy tranquilo y auténtico. El acceso un poco complicado pero vale la pena.', 'fechaResena': '2024-03-10'},
      {'id': 'rev3', 'nombreUsuario': 'Sofia M.', 'fotoUsuarioUrl': null, 'calificacion': 4.5, 'comentario': 'Excelente comida y vistas. Aprendimos mucho sobre la cultura local.', 'fechaResena': '2024-02-20'},
    ];

    final textTheme = Theme.of(context).textTheme;

    if (mockResenas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Text('Aún no hay reseñas para este alojamiento. ¡Sé el primero!'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text('${mockResenas.length} Reseña${mockResenas.length == 1 ? '' : 's'}', style: textTheme.titleLarge),
        ),
        // Placeholder for overall rating summary
        // Row(children: [ _buildStarRating(4.6, size: 22), SizedBox(width:8), Text('4.6 Promedio', style: textTheme.titleMedium)]),
        // const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // If inside another scrollview
          itemCount: mockResenas.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final resena = mockResenas[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: (resena['fotoUsuarioUrl'] as String?) != null ? NetworkImage(resena['fotoUsuarioUrl'] as String) : null,
                        child: (resena['fotoUsuarioUrl'] as String?) == null ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(resena['nombreUsuario'] as String? ?? 'Anónimo', style: textTheme.titleMedium),
                          Text(resena['fechaResena'] as String? ?? '', style: textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStarRating(resena['calificacion'] as double? ?? 0.0),
                  if (resena['comentario'] != null && (resena['comentario'] as String).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(resena['comentario'] as String, style: textTheme.bodyMedium),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
