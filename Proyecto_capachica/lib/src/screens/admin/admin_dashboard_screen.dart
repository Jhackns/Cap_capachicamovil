import 'package:flutter/material.dart';
import '../admin/manage_alojamientos_screen.dart';
import '../admin/manage_servicios_screen.dart';
 // Assuming this exists

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder data (replace with service call)
    final alojamientoCount = 5; // Example
    final servicioCount = 10; // Example

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Administrativo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.hotel),
                title: const Text('Alojamientos'),
                subtitle: Text('$alojamientoCount registrados'),
                onTap: () => Navigator.pushNamed(context, '/admin/manage-alojamientos'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Servicios'),
                subtitle: Text('$servicioCount registrados'),
                onTap: () => Navigator.pushNamed(context, '/admin/manage-servicios'),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/alojamientos/list'),
              child: const Text('Ver Lista de Alojamientos'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}