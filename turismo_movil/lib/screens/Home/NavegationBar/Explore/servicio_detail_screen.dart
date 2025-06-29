import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/servicio.dart';
import '../../../../providers/auth_provider.dart';
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
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

    setState(() => _isCheckingAvailability = true);

    try {
      // Formatear fecha y horas para la API
      final fecha = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final horaInicio = _selectedStartTime!.format(context);
      final horaFin = _selectedEndTime!.format(context);
      
      // Convertir formato de hora de 12h a 24h
      final horaInicio24 = _selectedStartTime!.hour.toString().padLeft(2, '0') + ':' + 
                          _selectedStartTime!.minute.toString().padLeft(2, '0') + ':00';
      final horaFin24 = _selectedEndTime!.hour.toString().padLeft(2, '0') + ':' + 
                       _selectedEndTime!.minute.toString().padLeft(2, '0') + ':00';
      
      // Verificar disponibilidad real
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
            content: Text('Servicio no disponible en la fecha y horario seleccionados. Intenta con otro horario.'),
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
            
            // Bloque 5: Mapa (placeholder)
            _buildMapPlaceholder(),
            
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
          const SizedBox(height: 12),
          // Por ahora mostramos un horario genérico
          // TODO: Implementar horarios reales desde la base de datos
          _buildScheduleItem('Lunes', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Martes', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Miércoles', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Jueves', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Viernes', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Sábado', 'Disponible', '12:00 PM - 3:00 PM'),
          _buildScheduleItem('Domingo', 'No disponible', '-'),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String status, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: status == 'Disponible' ? Colors.green.shade100 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                color: status == 'Disponible' ? Colors.green.shade700 : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityChecker() {
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
          
          // Selector de fecha
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_selectedDate != null 
              ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
              : 'Seleccionar fecha'),
            onTap: _selectDate,
            tileColor: Colors.grey.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          
          const SizedBox(height: 8),
          
          // Selectores de hora
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_selectedStartTime != null 
                    ? _selectedStartTime!.format(context)
                    : 'Hora inicio'),
                  onTap: _selectStartTime,
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_selectedEndTime != null 
                    ? _selectedEndTime!.format(context)
                    : 'Hora fin'),
                  onTap: _selectEndTime,
                  tileColor: Colors.grey.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botón verificar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingAvailability ? null : _checkAvailability,
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
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                      'El servicio no está disponible en la fecha y horario seleccionados. Intenta con otro horario.',
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

  Widget _buildMapPlaceholder() {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Mapa en desarrollo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
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
      buttonText = 'Agregar al Carrito';
      onPressed = () {
        // TODO: Implementar funcionalidad de carrito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidad de carrito próximamente disponible'),
            backgroundColor: Colors.blue,
          ),
        );
      };
      buttonColor = Colors.green;
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

  IconData _getButtonIcon(bool isAuthenticated, bool isAvailable) {
    if (!isAuthenticated) return Icons.login;
    if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
      return Icons.schedule;
    }
    if (_availabilityResult == null) return Icons.check_circle;
    if (isAvailable) return Icons.shopping_cart;
    return Icons.cancel;
  }
} 