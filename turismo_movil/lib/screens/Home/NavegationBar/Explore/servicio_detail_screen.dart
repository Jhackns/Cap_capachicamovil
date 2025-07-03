import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../models/servicio.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/carrito_provider.dart';
import '../../../../services/servicio_service.dart';
import '../../../../config/api_config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class ServicioDetailScreen extends StatefulWidget {
  final Servicio servicio;
  
  const ServicioDetailScreen({
    Key? key,
    required this.servicio,
  }) : super(key: key);

  @override
  State<ServicioDetailScreen> createState() => _ServicioDetailScreenState();
}

class _ServicioDetailScreenState extends State<ServicioDetailScreen> {
  final ServicioService _servicioService = ServicioService();
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  bool _isCheckingAvailability = false;
  String? _availabilityResult;
  List<Servicio> _relatedServices = [];
  bool _loadingRelated = true;
  int _currentImageIndex = 0;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedServices();
  }

  Future<void> _loadRelatedServices() async {
    try {
      setState(() => _loadingRelated = true);
      
      // Obtener la primera categoría del servicio actual
      final categoria = widget.servicio.categorias.isNotEmpty ? widget.servicio.categorias.first : '';
      
      if (categoria.isNotEmpty) {
        // Usar el nuevo método para obtener servicios relacionados
        final serviciosData = await _servicioService.getServiciosRelacionados(
          widget.servicio.id, 
          categoria
        );
        
        final servicios = serviciosData.map((data) => Servicio.fromJson(data)).toList();
        
        setState(() {
          _relatedServices = servicios;
          _loadingRelated = false;
        });
      } else {
        setState(() => _loadingRelated = false);
      }
    } catch (e) {
      setState(() => _loadingRelated = false);
      print('Error cargando servicios relacionados: $e');
    }
  }

  Future<void> _selectDate() async {
    final diasDisponibles = widget.servicio.getDiasDisponibles();
    
    // Si no hay horarios configurados, mostrar mensaje
    if (diasDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este servicio no tiene horarios configurados. Contacta al emprendedor.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Encontrar la primera fecha disponible a partir de hoy
    DateTime fechaInicial = DateTime.now();
    final diasSemana = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];
    
    // Buscar la primera fecha disponible
    for (int i = 0; i < 7; i++) {
      final fecha = DateTime.now().add(Duration(days: i));
      final diaSemana = diasSemana[fecha.weekday % 7];
      
      if (diasDisponibles.contains(diaSemana)) {
        fechaInicial = fecha;
        break;
      }
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        // Obtener el día de la semana en español
        final diaSemana = diasSemana[date.weekday % 7];
        
        // Permitir seleccionar solo días en los que el servicio esté disponible
        return diasDisponibles.contains(diaSemana);
      },
      helpText: 'Selecciona una fecha disponible',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _availabilityResult = null;
        _isAvailable = false;
      });
    }
  }

  Future<void> _selectStartTime() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una fecha')),
      );
      return;
    }
    
    // Obtener horarios disponibles para el día seleccionado
    final diasSemana = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];
    final diaSemana = diasSemana[_selectedDate!.weekday % 7];
    final horariosDia = widget.servicio.getHorariosPorDia(diaSemana);
    
    if (horariosDia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay horarios disponibles para este día')),
      );
      return;
    }
    
    // Obtener la hora de inicio más temprana como hora inicial sugerida
    TimeOfDay? horaInicial;
    if (horariosDia.isNotEmpty) {
      final primerHorario = horariosDia.first;
      final horaInicioStr = primerHorario['hora_inicio']?.toString() ?? '08:00:00';
      final partes = horaInicioStr.split(':');
      horaInicial = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaInicial ?? TimeOfDay.now(),
      helpText: 'Selecciona hora de inicio',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    
    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
        _availabilityResult = null;
        _isAvailable = false;
      });
    }
  }

  Future<void> _selectEndTime() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una fecha')),
      );
      return;
    }
    
    if (_selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona una hora de inicio')),
      );
      return;
    }
    
    // Obtener horarios disponibles para el día seleccionado
    final diasSemana = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];
    final diaSemana = diasSemana[_selectedDate!.weekday % 7];
    final horariosDia = widget.servicio.getHorariosPorDia(diaSemana);
    
    if (horariosDia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay horarios disponibles para este día')),
      );
      return;
    }
    
    // Obtener la hora de fin más tardía como hora final sugerida
    TimeOfDay? horaFinal;
    if (horariosDia.isNotEmpty) {
      final ultimoHorario = horariosDia.last;
      final horaFinStr = ultimoHorario['hora_fin']?.toString() ?? '18:00:00';
      final partes = horaFinStr.split(':');
      horaFinal = TimeOfDay(
        hour: int.parse(partes[0]),
        minute: int.parse(partes[1]),
      );
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horaFinal ?? _selectedStartTime!,
      helpText: 'Selecciona hora de fin',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    
    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
        _availabilityResult = null;
        _isAvailable = false;
      });
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona fecha y horarios')),
      );
      return;
    }

    // Validar que la hora de fin sea después de la hora de inicio
    final startMinutes = _selectedStartTime!.hour * 60 + _selectedStartTime!.minute;
    final endMinutes = _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
    
    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser posterior a la hora de inicio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCheckingAvailability = true);

    try {
      // Formatear fecha y horas para la API
      final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final horaInicio24 = _selectedStartTime!.hour.toString().padLeft(2, '0') + ':' + 
                          _selectedStartTime!.minute.toString().padLeft(2, '0') + ':00';
      final horaFin24 = _selectedEndTime!.hour.toString().padLeft(2, '0') + ':' + 
                       _selectedEndTime!.minute.toString().padLeft(2, '0') + ':00';
      
      // Obtener información del día seleccionado para mostrar mensajes más específicos
      final diasSemana = ['domingo', 'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado'];
      final diaSemana = diasSemana[_selectedDate!.weekday % 7];
      final horariosDia = widget.servicio.getHorariosPorDia(diaSemana);
      
      if (horariosDia.isEmpty) {
        setState(() {
          _isAvailable = false;
          _availabilityResult = 'No disponible';
          _isCheckingAvailability = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El servicio no está disponible los ${_capitalize(diaSemana)}s'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Verificar si el horario solicitado está dentro de los horarios disponibles
      bool horarioValido = false;
      String horariosDisponibles = '';
      
      for (final horario in horariosDia) {
        final horarioInicio = horario['hora_inicio']?.toString() ?? '';
        final horarioFin = horario['hora_fin']?.toString() ?? '';
        
        // Verificar si el horario solicitado está dentro del horario disponible
        if (_compararHoras(horaInicio24, horarioInicio) >= 0 && 
            _compararHoras(horaFin24, horarioFin) <= 0) {
          horarioValido = true;
          break;
        }
        
        // Agregar a la lista de horarios disponibles para el mensaje
        if (horariosDisponibles.isNotEmpty) horariosDisponibles += ', ';
        horariosDisponibles += '${horarioInicio.substring(0, 5)} - ${horarioFin.substring(0, 5)}';
      }
      
      if (!horarioValido) {
        setState(() {
          _isAvailable = false;
          _availabilityResult = 'No disponible';
          _isCheckingAvailability = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Horario no válido. Horarios disponibles: $horariosDisponibles'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Si pasa la validación local, verificar disponibilidad real con la API
      final disponible = await _servicioService.verificarDisponibilidad(
        widget.servicio.id,
        fecha,
        horaInicio24,
        horaFin24,
      );
      
      setState(() {
        _isAvailable = disponible;
        _availabilityResult = disponible ? 'Disponible' : 'No disponible';
        _isCheckingAvailability = false;
      });
      
      if (disponible) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicio disponible para la fecha y horario seleccionados'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El servicio no está disponible en este horario. Intenta con otro horario.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isCheckingAvailability = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar disponibilidad: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método auxiliar para comparar horas
  int _compararHoras(String hora1, String hora2) {
    try {
      final partes1 = hora1.split(':');
      final partes2 = hora2.split(':');
      
      final minutos1 = int.parse(partes1[0]) * 60 + int.parse(partes1[1]);
      final minutos2 = int.parse(partes2[0]) * 60 + int.parse(partes2[1]);
      
      return minutos1.compareTo(minutos2);
    } catch (e) {
      print('Error comparando horas: $hora1 vs $hora2 - $e');
      return 0;
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamed(context, '/login');
  }

  Future<void> _contactWhatsApp() async {
    final telefono = widget.servicio.emprendedorTelefono;
    if (telefono == null || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay número de teléfono disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Limpiar el número de teléfono (remover espacios, guiones, etc.)
    String numeroLimpio = telefono.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Si no empieza con +, agregar código de país de Perú
    if (!numeroLimpio.startsWith('+')) {
      if (numeroLimpio.startsWith('51')) {
        numeroLimpio = '+$numeroLimpio';
      } else if (numeroLimpio.startsWith('0')) {
        numeroLimpio = '+51${numeroLimpio.substring(1)}';
      } else {
        numeroLimpio = '+51$numeroLimpio';
      }
    }

    final mensaje = 'Hola! Me interesa el servicio "${widget.servicio.nombre}". ¿Podrías darme más información?';
    final url = 'https://wa.me/$numeroLimpio?text=${Uri.encodeComponent(mensaje)}';

    try {
      final uri = Uri.parse(url);
      
      // Intentar abrir directamente sin verificar canLaunchUrl
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!result) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
      
      // Mostrar información del error y opciones alternativas
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No se pudo abrir WhatsApp'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error: $e'),
                const SizedBox(height: 16),
                const Text('Información de contacto:'),
                const SizedBox(height: 8),
                Text('• Número: $numeroLimpio'),
                Text('• Mensaje: $mensaje'),
                const SizedBox(height: 8),
                const Text('Puedes copiar esta información y contactar manualmente.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    }
  }

  String _getCategoryIcon(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('alojamiento') || cat.contains('hospedaje')) return '🏨';
    if (cat.contains('alimentacion') || cat.contains('restaurante')) return '🍽️';
    if (cat.contains('artesania') || cat.contains('artesanal')) return '🎨';
    if (cat.contains('transporte') || cat.contains('viaje')) return '🚗';
    if (cat.contains('actividad') || cat.contains('turismo')) return '🏃';
    return '🏢';
  }

  List<String> _getImageUrls() {
    final sliders = widget.servicio.sliders;
    if (sliders.isNotEmpty) {
      return sliders.map((slider) {
        final imagen = slider['imagen'];
        if (imagen != null && imagen.toString().isNotEmpty) {
          // Si la imagen es una URL completa, usarla directamente
          if (imagen.toString().startsWith('http')) {
            return imagen.toString();
          }
          // Si es una ruta relativa, construir la URL completa
          return '${ApiConfig.baseUrl}/storage/$imagen';
        }
        return '';
      }).where((url) => url.isNotEmpty).toList();
    }
    
    // Imagen por defecto si no hay sliders
    return ['https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80'];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final categoria = widget.servicio.categorias.isNotEmpty ? widget.servicio.categorias.first : 'General';
    final imageUrls = _getImageUrls();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicio.nombre),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes
            _buildImageCarousel(imageUrls),
            
            // Bloque 1: Información del servicio
            _buildServiceInfo(categoria),
            
            // Bloque 2: Capacidad y ubicación
            _buildCapacityAndLocation(),
            
            // Bloque 3: Horarios de disponibilidad
            _buildAvailabilitySchedule(),
            
            // Bloque 4: Verificar disponibilidad
            _buildAvailabilityChecker(),
            
            // Bloque 5: Mapa
            _buildServiceMap(),
            
            // Bloque 6: Información del emprendedor
            _buildEntrepreneurInfo(),
            
            // Bloque 7: Servicios relacionados
            _buildRelatedServices(),
            
            const SizedBox(height: 100), // Espacio para botones flotantes
          ],
        ),
      ),
      bottomSheet: _buildActionButtons(authProvider),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return Container(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 250,
              viewportFraction: 1.0,
              enableInfiniteScroll: imageUrls.length > 1,
              autoPlay: imageUrls.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: imageUrls.map((url) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                child: ClipRect(
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Imagen no disponible',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          // Indicadores de página
          if (imageUrls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: imageUrls.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(String categoria) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges de categoría y estado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_getCategoryIcon(categoria), style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      categoria,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.servicio.estado ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.servicio.estado ? 'Disponible' : 'No disponible',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nombre del servicio
          Text(
            widget.servicio.nombre,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          
          // Descripción
          Text(
            widget.servicio.descripcion,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Precio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Text(
              'S/. ${widget.servicio.precio.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityAndLocation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capacidad y Ubicación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Capacidad: ${widget.servicio.capacidad} personas',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ubicación: ${widget.servicio.ubicacionReferencia ?? 'No especificada'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySchedule() {
    final horariosCompletos = widget.servicio.getHorariosCompletos();
    final diasSemana = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    final nombresDias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horarios de Disponibilidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cards de horarios mejoradas
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: diasSemana.length,
            itemBuilder: (context, index) {
              final dia = diasSemana[index];
              final nombreDia = nombresDias[index];
              final horario = horariosCompletos[dia] ?? 'No disponible';
              final estaDisponible = horario != 'No disponible';
              
              return Container(
                decoration: BoxDecoration(
                  color: estaDisponible ? Colors.white : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: estaDisponible ? Colors.green.shade200 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Día de la semana
                      Text(
                        nombreDia,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: estaDisponible ? const Color(0xFF6A1B9A) : Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: estaDisponible ? Colors.green.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: estaDisponible ? Colors.green.shade300 : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          estaDisponible ? 'Disponible' : 'No disponible',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: estaDisponible ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Horario
                      Expanded(
                        child: Center(
                          child: Text(
                            horario,
                            style: TextStyle(
                              fontSize: 12,
                              color: estaDisponible ? Colors.black87 : Colors.grey.shade500,
                              fontWeight: estaDisponible ? FontWeight.w500 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Mostrar información adicional si no hay horarios
          if (widget.servicio.horarios.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sin horarios configurados',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Este servicio no tiene horarios configurados. Contacta al emprendedor para más información.',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityChecker() {
    final diasDisponibles = widget.servicio.getDiasDisponibles();
    final tieneHorarios = diasDisponibles.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verificar Disponibilidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 12),
          
          // Mostrar información sobre días disponibles
          if (tieneHorarios) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Días disponibles:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diasDisponibles.map((dia) => _capitalize(dia)).join(', '),
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Selector de fecha mejorado
          GestureDetector(
            onTap: tieneHorarios ? _selectDate : null,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tieneHorarios ? Colors.white : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: tieneHorarios ? Colors.purple.shade300 : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: tieneHorarios ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: tieneHorarios ? Colors.purple : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedDate != null 
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Seleccionar fecha',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: tieneHorarios ? Colors.black87 : Colors.grey,
                          ),
                        ),
                        if (!tieneHorarios) ...[
                          const SizedBox(height: 4),
                          Text(
                            'No hay horarios configurados',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (tieneHorarios)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.purple,
                      size: 16,
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Selectores de hora mejorados
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (_selectedDate != null && tieneHorarios) ? _selectStartTime : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_selectedDate != null && tieneHorarios) ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_selectedDate != null && tieneHorarios) ? Colors.blue.shade300 : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: (_selectedDate != null && tieneHorarios) ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: (_selectedDate != null && tieneHorarios) ? Colors.blue : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedStartTime != null 
                            ? _selectedStartTime!.format(context)
                            : 'Hora inicio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (_selectedDate != null && tieneHorarios) ? Colors.black87 : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedDate == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona fecha primero',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: (_selectedStartTime != null && tieneHorarios) ? _selectEndTime : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (_selectedStartTime != null && tieneHorarios) ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_selectedStartTime != null && tieneHorarios) ? Colors.green.shade300 : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: (_selectedStartTime != null && tieneHorarios) ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: (_selectedStartTime != null && tieneHorarios) ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedEndTime != null 
                            ? _selectedEndTime!.format(context)
                            : 'Hora fin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (_selectedStartTime != null && tieneHorarios) ? Colors.black87 : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_selectedStartTime == null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona hora inicio',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón verificar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (!tieneHorarios || _isCheckingAvailability) ? null : _checkAvailability,
              icon: _isCheckingAvailability 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle),
              label: Text(_isCheckingAvailability ? 'Verificando...' : 'Verificar Disponibilidad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          if (_availabilityResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _availabilityResult == 'Disponible' ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _availabilityResult == 'Disponible' ? Colors.green.shade300 : Colors.red.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _availabilityResult == 'Disponible' ? Icons.check_circle : Icons.cancel,
                        color: _availabilityResult == 'Disponible' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _availabilityResult!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _availabilityResult == 'Disponible' ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  if (_availabilityResult == 'No disponible') ...[
                    const SizedBox(height: 8),
                    Text(
                      'El servicio no está disponible en la fecha y horario seleccionados. Revisa los horarios del servicio o intenta con otro horario.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceMap() {
    final lat = widget.servicio.latitud;
    final lng = widget.servicio.longitud;
    if (lat == null || lng == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'Ubicación no disponible',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final LatLng point = LatLng(lat, lng);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ubicación',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZ3JpbWFsZG9hcnJlZG9uZG8iLCJhIjoiY21hYmJvMGpoMmF6YjJrb29tNnJ0MXQ1dyJ9.Em9vVlsuF3-ddqRnxTMYAw',
                    userAgentPackageName: 'com.example.turismo_capachica',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrepreneurInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información del Emprendedor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.servicio.emprendedor,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rubro: ${widget.servicio.categorias.join(', ')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.servicio.emprendedorTelefonoText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.servicio.emprendedorEmailText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.servicio.emprendedorUbicacionText,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  if (widget.servicio.emprendedorDescripcionText != 'Sin descripción') ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.servicio.emprendedorDescripcionText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedServices() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicios Relacionados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingRelated)
            const Center(child: CircularProgressIndicator())
          else if (_relatedServices.isEmpty)
            const Text('No hay servicios relacionados disponibles')
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _relatedServices.length,
              itemBuilder: (context, index) {
                final servicio = _relatedServices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(servicio.nombre),
                    subtitle: Text(servicio.emprendedor),
                    trailing: Text(
                      'S/. ${servicio.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServicioDetailScreen(servicio: servicio),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider authProvider) {
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
    
    // Determinar el texto y estado del botón principal
    String buttonText;
    VoidCallback? onPressed;
    bool isEnabled = true;
    Color buttonColor = const Color(0xFF9C27B0);

    if (!authProvider.isAuthenticated) {
      buttonText = 'Iniciar Sesión';
      onPressed = _navigateToLogin;
    } else if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      buttonText = 'Seleccionar fecha y hora';
      onPressed = () {
        // Mostrar mensaje para seleccionar fecha y hora
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona una fecha y horario para verificar disponibilidad'),
            backgroundColor: Colors.orange,
          ),
        );
      };
    } else if (_availabilityResult == null) {
      buttonText = 'Verificar Disponibilidad';
      onPressed = _isCheckingAvailability ? null : _checkAvailability;
      isEnabled = !_isCheckingAvailability;
    } else if (_isAvailable) {
      // Verificar si el servicio ya está en el carrito
      final horaInicio24 = _selectedStartTime!.hour.toString().padLeft(2, '0') + ':' + 
                          _selectedStartTime!.minute.toString().padLeft(2, '0') + ':00';
      final horaFin24 = _selectedEndTime!.hour.toString().padLeft(2, '0') + ':' + 
                       _selectedEndTime!.minute.toString().padLeft(2, '0') + ':00';
      
      final yaEnCarrito = carritoProvider.servicioEnCarrito(
        servicioId: widget.servicio.id,
        fecha: _selectedDate!,
        horaInicio: horaInicio24,
        horaFin: horaFin24,
      );
      
      if (yaEnCarrito) {
        buttonText = 'Ya en el Carrito';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este servicio ya está en tu carrito'),
              backgroundColor: Colors.orange,
            ),
          );
        };
        buttonColor = Colors.orange;
      } else {
        buttonText = 'Agregar al Carrito';
        onPressed = () => _agregarAlCarrito(carritoProvider);
        buttonColor = Colors.green;
      }
    } else {
      buttonText = 'No Disponible';
      onPressed = null;
      isEnabled = false;
      buttonColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isEnabled ? onPressed : null,
              icon: Icon(
                _getButtonIcon(authProvider.isAuthenticated, _isAvailable),
                size: 20,
              ),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: _contactWhatsApp,
              icon: const FaIcon(
                FontAwesomeIcons.whatsapp,
                size: 20,
              ),
              label: const Text(
                'WhatsApp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 2,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _agregarAlCarrito(CarritoProvider carritoProvider) async {
    print('🛒 _agregarAlCarrito iniciado');
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      print('❌ Fecha o horarios no seleccionados');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona fecha y horario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final horaInicio24 = _selectedStartTime!.hour.toString().padLeft(2, '0') + ':' + 
                        _selectedStartTime!.minute.toString().padLeft(2, '0') + ':00';
    final horaFin24 = _selectedEndTime!.hour.toString().padLeft(2, '0') + ':' + 
                     _selectedEndTime!.minute.toString().padLeft(2, '0') + ':00';
    // Verificar duplicado antes de agregar
    final yaEnCarrito = carritoProvider.servicioEnCarrito(
      servicioId: widget.servicio.id,
      fecha: _selectedDate!,
      horaInicio: horaInicio24,
      horaFin: horaFin24,
    );
    if (yaEnCarrito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este servicio ya está en tu carrito para la fecha y horario seleccionados.'),
          backgroundColor: Colors.orange,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushNamedAndRemoveUntil(context, '/explore', (route) => false);
      return;
    }
    // Verificar autenticación
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('🔐 Usuario autenticado: ${authProvider.isAuthenticated}');
    if (!authProvider.isAuthenticated) {
      print('❌ Usuario no autenticado');
      return;
    }

    // Mostrar indicador de carga
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Agregando al carrito...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Agregar al carrito
    final success = await carritoProvider.agregarItem(
      servicioId: widget.servicio.id,
      nombreServicio: widget.servicio.nombre,
      nombreEmprendedor: widget.servicio.emprendedor,
      fecha: _selectedDate!,
      horaInicio: horaInicio24,
      horaFin: horaFin24,
      precio: widget.servicio.precio,
      emprendedorId: widget.servicio.emprendedorId,
    );

    print('📡 Resultado de agregarItem: $success');

    // Cerrar el snackbar de carga
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${widget.servicio.nombre} agregado al carrito'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ver Carrito',
            textColor: Colors.white,
            onPressed: () async {
              await Navigator.pushNamedAndRemoveUntil(
                context,
                '/main',
                (route) => false,
                arguments: {'initialTab': 2},
              );
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al agregar al carrito. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getButtonIcon(bool isAuthenticated, bool isAvailable) {
    if (!isAuthenticated) return Icons.login;
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      return Icons.schedule;
    }
    if (_availabilityResult == null) return Icons.check_circle;
    if (isAvailable) {
      // Verificar si ya está en el carrito
      if (_selectedDate != null && _selectedStartTime != null && _selectedEndTime != null) {
        final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
        final horaInicio24 = _selectedStartTime!.hour.toString().padLeft(2, '0') + ':' + 
                            _selectedStartTime!.minute.toString().padLeft(2, '0') + ':00';
        final horaFin24 = _selectedEndTime!.hour.toString().padLeft(2, '0') + ':' + 
                         _selectedEndTime!.minute.toString().padLeft(2, '0') + ':00';
        
        final yaEnCarrito = carritoProvider.servicioEnCarrito(
          servicioId: widget.servicio.id,
          fecha: _selectedDate!,
          horaInicio: horaInicio24,
          horaFin: horaFin24,
        );
        
        if (yaEnCarrito) {
          return Icons.shopping_cart;
        }
      }
      return Icons.shopping_cart;
    }
    return Icons.cancel;
  }

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1).toLowerCase();
  }
} 