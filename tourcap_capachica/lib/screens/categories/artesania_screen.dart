import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import 'base_category_screen.dart';

class ArtesaniaScreen extends StatelessWidget {
  const ArtesaniaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final artesanias = getEntrepreneursByCategory('Artesanía');
    
    return BaseCategoryScreen(
      categoryName: 'Artesanía',
      entrepreneurs: artesanias,
    );
  }
}
