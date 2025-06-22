import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../blocs/reserva_bloc/reserva_bloc.dart';
// import '../../models/alojamiento/alojamiento_model.dart'; // To pass alojamiento info

class CreateReservaScreen extends StatefulWidget {
  // final Alojamiento alojamiento; // Pass the accommodation details
  final Map<String, dynamic> alojamientoData; // Placeholder for Alojamiento

  const CreateReservaScreen({super.key, required this.alojamientoData});

  @override
  State<CreateReservaScreen> createState() => _CreateReservaScreenState();
}

class _CreateReservaScreenState extends State<CreateReservaScreen> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int _numeroHuespedes = 1;
  final _notasController = TextEditingController();

  double get _precioPorNoche => (widget.alojamientoData['precioPorNoche'] as num? ?? 0.0).toDouble();
  int get _noches {
    if (_fechaInicio == null || _fechaFin == null || _fechaFin!.isBefore(_fechaInicio!)) {
      return 0;
    }
    return _fechaFin!.difference(_fechaInicio!).inDays;
  }
  double get _costoTotal => _precioPorNoche * _noches * _numeroHuespedes; // Simplified calculation

  Future<void> _selectFecha(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isInicio ? _fechaInicio : _fechaFin) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _fechaInicio = picked;
          if (_fechaFin != null && _fechaFin!.isBefore(_fechaInicio!)) {
            _fechaFin = null; // Reset if invalid range
          }
        } else {
          _fechaFin = picked;
           if (_fechaInicio != null && _fechaFin!.isBefore(_fechaInicio!)) {
            _fechaInicio = null; // Reset if invalid range
          }
        }
      });
    }
  }

  void _submitReserva() {
    if (_fechaInicio == null || _fechaFin == null || _noches <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un rango de fechas válido.')),
      );
      return;
    }
    // final reservaBloc = BlocProvider.of<ReservaBloc>(context);
    // In a real app, get an actual user ID
    // String currentUserId = context.read<AuthBloc>().state.user.id; // Example
    String currentUserId = 'mock_user_id';

    // reservaBloc.add(CreateReserva(
    //   alojamientoId: widget.alojamientoData['id'] as String, // widget.alojamiento.id,
    //   usuarioId: currentUserId,
    //   fechaInicio: _fechaInicio!,
    //   fechaFin: _fechaFin!,
    //   numeroHuespedes: _numeroHuespedes,
    //   costoTotal: _costoTotal,
    //   notasEspeciales: _notasController.text,
    // ));
    print('Submit Reserva: Aloj ID: ${widget.alojamientoData['id']}, UserID: $currentUserId, Fechas: $_fechaInicio - $_fechaFin, Huéspedes: $_numeroHuespedes, Costo: $_costoTotal');

    // Placeholder for success/failure message based on Bloc state change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud de reserva enviada (placeholder).')),
    );
    Navigator.of(context).pop(); // Go back after attempting
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservar ${widget.alojamientoData['nombre'] ?? 'Alojamiento'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fechas de Estadía', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaInicio == null ? 'Fecha Inicio' : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'),
                    onPressed: () => _selectFecha(context, true),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('a'),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_fechaFin == null ? 'Fecha Fin' : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'),
                    onPressed: () => _selectFecha(context, false),
                  ),
                ),
              ],
            ),
            if (_noches > 0) Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Center(child: Text('$_noches noche${_noches == 1 ? '' : 's'}', style: textTheme.titleMedium)),
            ),
            const Divider(height: 32),

            Text('Número de Huéspedes', style: textTheme.titleLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: _numeroHuespedes > 1 ? () => setState(() => _numeroHuespedes--) : null),
                Text('$_numeroHuespedes', style: textTheme.titleMedium),
                IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => _numeroHuespedes++)),
              ],
            ),
            const Divider(height: 32),

            Text('Notas Adicionales (Opcional)', style: textTheme.titleLarge),
            TextField(
              controller: _notasController,
              decoration: const InputDecoration(hintText: 'Ej: Preferencia de habitación, hora de llegada...'),
              maxLines: 3,
            ),
            const Divider(height: 32),

            Text('Resumen de Costo', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_noches > 0) ...[
              ListTile(
                title: Text('\$$_precioPorNoche x $_noches noche${_noches == 1 ? '' : 's'} x $_numeroHuespedes huésped${_numeroHuespedes == 1 ? '' : 's'}'),
                trailing: Text('\$${_costoTotal.toStringAsFixed(2)} PEN', style: textTheme.titleMedium),
              ),
              // Add other fees if applicable (service fee, taxes)
              const ListTile(
                title: Text('Tarifa de servicio (ejemplo)'),
                trailing: Text('25.00 PEN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              ListTile(
                title: Text('Total Estimado', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                trailing: Text('\$${(_costoTotal + 25.00).toStringAsFixed(2)} PEN', style: textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor)),
              ),
            ] else
              const Text('Selecciona las fechas para ver el costo.'),
            const SizedBox(height: 24),
            // BlocListener<ReservaBloc, ReservaState>( // For handling feedback
            //   listener: (context, state) {
            //     if (state is ReservaCreationSuccess) {
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('¡Reserva creada con éxito! ID: ${state.reserva.id}'), backgroundColor: Colors.green));
            //       Navigator.of(context).pop(); // Pop this screen
            //     } else if (state is ReservaCreationFailure) {
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear reserva: ${state.message}'), backgroundColor: Colors.red));
            //     }
            //   },
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton(
            //       style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.pink),
            //       onPressed: _costoTotal > 0 ? _submitReserva : null,
            //       child: const Text('Confirmar Reserva', style: TextStyle(fontSize: 18, color: Colors.white)),
            //     ),
            //   ),
            // ),
             SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.pink),
                  onPressed: _costoTotal > 0 ? _submitReserva : null,
                  child: const Text('Confirmar Reserva', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
