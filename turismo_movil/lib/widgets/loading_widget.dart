import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final Color? color;

  const LoadingWidget({
    Key? key,
    this.message = 'Cargando...',
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: color ?? Theme.of(context).colorScheme.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
