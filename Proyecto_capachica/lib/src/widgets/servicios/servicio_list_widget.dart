import 'package:flutter/material.dart';
// import '../../models/servicio/servicio_model.dart'; // If using full Servicio objects

class ServicioListWidget extends StatelessWidget {
  // final List<Servicio> servicios;
  final List<Map<String, String>> serviciosData; // Placeholder: e.g. [{'nombre': 'WiFi', 'iconoCode': 'wifi'}]

  const ServicioListWidget({
    super.key,
    required this.serviciosData,
    // required this.servicios
  });

  IconData _getIconData(String? iconCode) {
    // Basic mapping, can be expanded
    if (iconCode == null) return Icons.help_outline;
    switch (iconCode.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'free_breakfast':
      case 'desayuno':
        return Icons.free_breakfast;
      case 'kitchen':
      case 'cocina equipada':
        return Icons.kitchen;
      case 'local_parking':
      case 'estacionamiento':
        return Icons.local_parking;
      case 'pets':
      case 'pet friendly':
        return Icons.pets;
      case 'tour':
      case 'tour local':
        return Icons.tour;
      case 'local_laundry_service':
      case 'lavandería':
        return Icons.local_laundry_service;
      default:
        return Icons.room_service; // Default service icon
    }
  }

  @override
  Widget build(BuildContext context) {
    if (serviciosData.isEmpty) {
      return const Text('No hay servicios especiales detallados.');
    }

    // return Wrap(
    //   spacing: 8.0,
    //   runSpacing: 4.0,
    //   children: servicios.map((servicio) {
    //     return Chip(
    //       avatar: servicio.iconoUrlOrCode != null ? Icon(_getIconData(servicio.iconoUrlOrCode), size: 18) : null,
    //       label: Text(servicio.nombre),
    //       // You could add more details on tap if AlojamientoServicio data is available
    //     );
    //   }).toList(),
    // );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: serviciosData.map((data) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(_getIconData(data['iconoCode']), color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(data['nombre'] ?? 'Servicio', style: Theme.of(context).textTheme.bodyMedium)),
              // If there are details or costs, display them here
              if (data['detalles'] != null)
                Text(' (${data['detalles']})', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}
