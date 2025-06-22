import 'package:flutter/material.dart';
// import '../../models/servicio/servicio_model.dart';
// import '../../models/servicio/alojamiento_servicio_model.dart';
// import '../../blocs/servicio_bloc/servicio_bloc.dart'; // To load master services
// import 'package:flutter_bloc/flutter_bloc.dart';

class AlojamientoServicioEditorWidget extends StatefulWidget {
  final String alojamientoId;
  // final List<AlojamientoServicio> currentAlojamientoServicios; // Services currently linked
  // final List<Servicio> masterServicios; // All available master services

  // Using mock data for now
  final List<Map<String, dynamic>> currentAlojamientoServiciosData; // e.g. [{'servicioId': 'serv1', 'detalles': 'Detalle X'}]
  final List<Map<String, dynamic>> masterServiciosData; // e.g. [{'id': 'serv1', 'nombre': 'WiFi'}]


  const AlojamientoServicioEditorWidget({
    super.key,
    required this.alojamientoId,
    required this.currentAlojamientoServiciosData,
    required this.masterServiciosData,
  });

  @override
  State<AlojamientoServicioEditorWidget> createState() => _AlojamientoServicioEditorWidgetState();
}

class _AlojamientoServicioEditorWidgetState extends State<AlojamientoServicioEditorWidget> {
  late Set<String> _selectedServicioIds;
  late Map<String, TextEditingController> _detailControllers;

  @override
  void initState() {
    super.initState();
    _selectedServicioIds = widget.currentAlojamientoServiciosData.map((s) => s['servicioId'] as String).toSet();
    _detailControllers = {
      for (var s in widget.currentAlojamientoServiciosData)
        s['servicioId'] as String: TextEditingController(text: s['detallesAdicionales'] as String? ?? ''),
    };

    // Ensure controllers exist for all master services that might be selected
    for (var masterServicio in widget.masterServiciosData) {
      if (!_detailControllers.containsKey(masterServicio['id'] as String)) {
        _detailControllers[masterServicio['id'] as String] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _detailControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _onServicioToggle(String servicioId, bool? isSelected) {
    setState(() {
      if (isSelected == true) {
        _selectedServicioIds.add(servicioId);
        // Potentially add to AlojamientoBloc: LinkServicioToAlojamiento
        print('Link service ${servicioId} to alojamiento ${widget.alojamientoId}');
      } else {
        _selectedServicioIds.remove(servicioId);
        // Potentially add to AlojamientoBloc: UnlinkServicioFromAlojamiento (need AlojamientoServicio ID)
        print('Unlink service ${servicioId} from alojamiento ${widget.alojamientoId}');
        _detailControllers[servicioId]?.clear(); // Clear details if unselected
      }
    });
  }

  void _saveChanges() {
    // Here you would iterate through _selectedServicioIds
    // For each selected service, get details from _detailControllers[id].text
    // Then dispatch events to a BLoC (e.g., AlojamientoBloc or ServicioBloc)
    // to update the backend (LinkServicioToAlojamiento or batch update)
    List<Map<String, dynamic>> servicesToSave = [];
    for (String id in _selectedServicioIds) {
        servicesToSave.add({
            'servicioId': id,
            'detallesAdicionales': _detailControllers[id]?.text ?? ''
        });
    }
    print('Saving services for alojamiento ${widget.alojamientoId}: ${servicesToSave}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Servicios guardados (placeholder). Ver consola.')),
    );
  }


  @override
  Widget build(BuildContext context) {
    // In a real app, you'd use BlocBuilder to get masterServicios
    // BlocProvider.of<ServicioBloc>(context).add(LoadMasterServicios());

    if (widget.masterServiciosData.isEmpty) {
      return const Center(child: Text('No hay servicios maestros disponibles para asignar.'));
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seleccionar Servicios', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // If inside another scrollable
              itemCount: widget.masterServiciosData.length,
              itemBuilder: (context, index) {
                final masterServicio = widget.masterServiciosData[index];
                final servicioId = masterServicio['id'] as String;
                final bool isSelected = _selectedServicioIds.contains(servicioId);

                return Column(
                  children: [
                    CheckboxListTile(
                      title: Text(masterServicio['nombre'] as String),
                      value: isSelected,
                      onChanged: (bool? value) => _onServicioToggle(servicioId, value),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 16.0, bottom: 8.0),
                        child: TextFormField(
                          controller: _detailControllers[servicioId],
                          decoration: const InputDecoration(
                            labelText: 'Detalles adicionales / Costo (opcional)',
                            hintText: 'Ej: Desayuno de 7-9 AM, WiFi Fibra Óptica',
                          ),
                          onChanged: (text) {
                            // Could auto-save on change or have a save button
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Guardar Cambios en Servicios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
