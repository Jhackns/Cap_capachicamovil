import 'package:flutter/material.dart';
import '../../../models/entrepreneur.dart';
import '../../widgets/entrepreneur_card.dart';

class BaseCategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Entrepreneur> entrepreneurs;

  const BaseCategoryScreen({
    Key? key,
    required this.categoryName,
    required this.entrepreneurs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        centerTitle: true,
      ),
      body: entrepreneurs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay emprendimientos disponibles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entrepreneurs.length,
              itemBuilder: (context, index) {
                final entrepreneur = entrepreneurs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: EntrepreneurCard(entrepreneur: entrepreneur),
                );
              },
            ),
    );
  }
}
