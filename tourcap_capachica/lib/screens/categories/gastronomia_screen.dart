import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import 'base_category_screen.dart';

class GastronomiaScreen extends StatelessWidget {
  const GastronomiaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gastronomias = getEntrepreneursByCategory('Gastronomía');
    
    return BaseCategoryScreen(
      categoryName: 'Gastronomía',
      entrepreneurs: gastronomias,
    );
  }
}
