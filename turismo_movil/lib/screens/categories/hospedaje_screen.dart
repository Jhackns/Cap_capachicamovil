import 'package:flutter/material.dart';
import '../../data/sample_data.dart';
import 'base_category_screen.dart';

class HospedajeScreen extends StatelessWidget {
  const HospedajeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hospedajes = getEntrepreneursByCategory('Hospedaje');
    
    return BaseCategoryScreen(
      categoryName: 'Hospedaje',
      entrepreneurs: hospedajes,
    );
  }
}
