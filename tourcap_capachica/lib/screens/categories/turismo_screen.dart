import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import 'base_category_screen.dart';

class TurismoScreen extends StatelessWidget {
  const TurismoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final turismos = getEntrepreneursByCategory('Turismo');
    
    return BaseCategoryScreen(
      categoryName: 'Turismo',
      entrepreneurs: turismos,
    );
  }
}
