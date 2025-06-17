class Review {
  final int id;
  final String userName;
  final String comment;
  final double rating;
  final DateTime date;
  final String? userImage;

  Review({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
    this.userImage,
  });

  // Datos de ejemplo para el diseño
  static List<Review> getDummyReviews() {
    return [
      Review(
        id: 1,
        userName: 'María García',
        comment: 'Excelente servicio, muy atentos y el lugar es hermoso. Definitivamente volveré.',
        rating: 5.0,
        date: DateTime.now().subtract(const Duration(days: 2)),
        userImage: 'https://randomuser.me/api/portraits/women/1.jpg',
      ),
      Review(
        id: 2,
        userName: 'Juan Pérez',
        comment: 'Buen lugar, la comida es deliciosa y el ambiente es muy agradable.',
        rating: 4.5,
        date: DateTime.now().subtract(const Duration(days: 5)),
        userImage: 'https://randomuser.me/api/portraits/men/1.jpg',
      ),
      Review(
        id: 3,
        userName: 'Ana Martínez',
        comment: 'Muy buena atención y precios accesibles. Lo recomiendo.',
        rating: 4.0,
        date: DateTime.now().subtract(const Duration(days: 7)),
        userImage: 'https://randomuser.me/api/portraits/women/2.jpg',
      ),
    ];
  }
} 