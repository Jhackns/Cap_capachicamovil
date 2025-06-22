import 'package:flutter/material.dart';
import '../../utils/icon_utils.dart';
import '../../widgets/servicios/servicio_list_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Uncommented for BLoC
import '../../blocs/servicio_bloc/servicio_bloc.dart'; // Uncommented for BLoC
import '../../models/servicio/servicio_model.dart';
// Uncommented for BLoC // Import the utility clas
class ManageServiciosScreen extends StatelessWidget {
  const ManageServiciosScreen({super.key});

  void _showAddEditServicioDialog(BuildContext context, {Map<String, dynamic>? servicio}) {
    final _formKey = GlobalKey<FormState>();
    final _nombreController = TextEditingController(text: servicio?['nombre'] as String?);
    final _descripcionController = TextEditingController(text: servicio?['descripcion'] as String?);
    final _iconoController = TextEditingController(text: servicio?['iconoUrlOrCode'] as String?);
    final bool isEditing = servicio != null;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Servicio Maestro' : 'Agregar Servicio Maestro'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre del Servicio'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa un nombre' : null,
                  ),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
                  ),
                  TextFormField(
                    controller: _iconoController,
                    decoration: const InputDecoration(labelText: 'Código de Ícono (Ej: wifi, pets)'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Guardar Cambios' : 'Agregar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final servicioBloc = BlocProvider.of<ServicioBloc>(context);
                  if (isEditing) {
                    servicioBloc.add(UpdateMasterServicio(
                      servicioId: servicio!['id'] as String,
                      nombre: _nombreController.text,
                      descripcion: _descripcionController.text,
                      iconoUrlOrCode: _iconoController.text,
                    ));
                    print('Update Master Servicio: ID: ${servicio!['id']}, Nombre: ${_nombreController.text}');
                  } else {
                    servicioBloc.add(CreateMasterServicio(
                      nombre: _nombreController.text,
                      descripcion: _descripcionController.text,
                      iconoUrlOrCode: _iconoController.text,
                    ));
                    print('Create Master Servicio: Nombre: ${_nombreController.text}');
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mock list for non-BLoC testing
    final mockMasterServicios = [
      {'id': 'serv1', 'nombre': 'WiFi', 'descripcion': 'Acceso a internet', 'iconoUrlOrCode': 'wifi'},
      {'id': 'serv2', 'nombre': 'Desayuno', 'descripcion': 'Desayuno incluido', 'iconoUrlOrCode': 'free_breakfast'},
      {'id': 'serv3', 'nombre': 'Tour Local', 'descripcion': 'Paseo guiado', 'iconoUrlOrCode': 'tour'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Servicios Maestros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => BlocProvider.of<ServicioBloc>(context).add(LoadMasterServicios()),
          ),
        ],
      ),
    body: ListView.builder(
      itemCount: mockMasterServicios.length,
      itemBuilder: (context, index) {
        final item = mockMasterServicios[index] as Map<String, dynamic>;
        return ListTile(
          leading: item['iconoUrlOrCode'] != null ? Icon(IconUtils.getIconData(item['iconoUrlOrCode'])) : null,
          title: Text(item['nombre'] ?? ''),
          subtitle: Text(item['descripcion'] ?? 'Sin descripción'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showAddEditServicioDialog(context, servicio: item);
                  print('Edit ${item['id']}');
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  print('Delete ${item['id']}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Placeholder to Delete Master ${item['nombre']}')),
                  );
                },
              ),
            ],
          ),
        );
      },
    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditServicioDialog(context),
        tooltip: 'Agregar Servicio Maestro',
        child: const Icon(Icons.add),
      ),
    );
  }
}