import 'package:flutter/material.dart';

class HorarioSelector extends StatefulWidget {
  final List<Map<String, dynamic>> horarios;
  final Function(List<Map<String, dynamic>>) onHorariosChanged;

  const HorarioSelector({
    Key? key,
    required this.horarios,
    required this.onHorariosChanged,
  }) : super(key: key);

  @override
  State<HorarioSelector> createState() => _HorarioSelectorState();
}

class _HorarioSelectorState extends State<HorarioSelector> {
  late List<Map<String, dynamic>> _horarios;
  
  final List<String> _diasSemana = [
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'
  ];

  @override
  void initState() {
    super.initState();
    _horarios = List.from(widget.horarios);
    
    // Si no hay horarios, crear uno por defecto para cada día
    if (_horarios.isEmpty) {
      for (String dia in _diasSemana) {
        _horarios.add({
          'dia_semana': dia,
          'hora_inicio': '08:00:00',
          'hora_fin': '18:00:00',
          'activo': false,
        });
      }
    }
  }

  void _updateHorario(int index, String field, dynamic value) {
    setState(() {
      _horarios[index][field] = value;
    });
    widget.onHorariosChanged(_horarios);
  }

  void _toggleHorario(int index) {
    setState(() {
      _horarios[index]['activo'] = !(_horarios[index]['activo'] ?? false);
    });
    widget.onHorariosChanged(_horarios);
  }

  String _getDiaDisplayName(String dia) {
    switch (dia) {
      case 'lunes': return 'Lunes';
      case 'martes': return 'Martes';
      case 'miercoles': return 'Miércoles';
      case 'jueves': return 'Jueves';
      case 'viernes': return 'Viernes';
      case 'sabado': return 'Sábado';
      case 'domingo': return 'Domingo';
      default: return dia;
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _selectTime(BuildContext context, int index, bool isStart) async {
    final currentTime = isStart 
        ? _parseTime(_horarios[index]['hora_inicio'])
        : _parseTime(_horarios[index]['hora_fin']);
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeString = _formatTime(picked);
      final field = isStart ? 'hora_inicio' : 'hora_fin';
      _updateHorario(index, field, timeString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horarios Disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0)),
        ),
        const SizedBox(height: 16),
        ...List.generate(_horarios.length, (index) {
          final horario = _horarios[index];
          final isActive = horario['activo'] ?? false;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Día de la semana',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.black87 : Colors.grey,
                          ),
                        ),
                      ),
                      Switch(
                        value: isActive,
                        onChanged: (value) => _toggleHorario(index),
                        activeColor: const Color(0xFF9C27B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDiaDisplayName(horario['dia_semana']),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? const Color(0xFF9C27B0) : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hora inicio',
                              style: TextStyle(
                                fontSize: 14,
                                color: isActive ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: isActive ? () => _selectTime(context, index, true) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isActive ? Colors.grey.shade400 : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      horario['hora_inicio'].substring(0, 5),
                                      style: TextStyle(
                                        color: isActive ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hora fin',
                              style: TextStyle(
                                fontSize: 14,
                                color: isActive ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: isActive ? () => _selectTime(context, index, false) : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isActive ? Colors.grey.shade400 : Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      horario['hora_fin'].substring(0, 5),
                                      style: TextStyle(
                                        color: isActive ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        onChanged: (value) => _toggleHorario(index),
                        activeColor: const Color(0xFF9C27B0),
                      ),
                      Text(
                        'Activo',
                        style: TextStyle(
                          color: isActive ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'La hora de fin debe ser posterior a la hora de inicio',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
} 