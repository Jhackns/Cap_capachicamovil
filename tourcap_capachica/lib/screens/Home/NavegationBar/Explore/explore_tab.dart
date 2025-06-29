import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../../config/api_config.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/servicio_service.dart';
import '../../../../models/servicio.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  bool _isGrid = true;
  List<Servicio> _servicios = [];
  bool _loading = true;
  String? _error;

  final List<String> _filters = [
    'Todos',
    'Alojamientos',
    'Alimentación',
    'Artesanía',
    'Transporte',
    'Actividades',
  ];

  // Mapeo de filtros a categorías del backend
  final Map<String, String> _filterToCategory = {
    'Todos': '',
    'Alojamientos': 'Alojamiento',
    'Alimentación': 'Alimentación',
    'Artesanía': 'Artesanía',
    'Transporte': 'Transporte',
    'Actividades': 'Actividades',
  };

  List<Servicio> _filteredServicios = [];
  Timer? _searchTimer;
  bool _isSearching = false;
  final ServicioService _servicioService = ServicioService();

  @override
  void initState() {
    super.initState();
    _fetchServicios();
    
    // Agregar listener para la búsqueda con debounce
    _searchController.addListener(() {
      _debounceSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    super.dispose();
  }

  void _debounceSearch() {
    setState(() {
      _isSearching = true;
    });
    
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      _applySearchAndFilter();
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _applyFilter(int filterIndex) {
    setState(() {
      _selectedFilter = filterIndex;
      _applySearchAndFilter();
    });
  }

  void _applySearchAndFilter() {
    final searchTerm = _searchController.text.toLowerCase().trim();
    final filterName = _filters[_selectedFilter];
    final category = _filterToCategory[filterName] ?? '';
    
    List<Servicio> filtered = _servicios;
    
    // Aplicar filtro de categoría
    if (category.isNotEmpty) {
      filtered = filtered.where((servicio) {
        return servicio.categorias.any((cat) => cat.toLowerCase() == category.toLowerCase());
      }).toList();
    }
    
    // Aplicar búsqueda
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((servicio) {
        final nombre = servicio.nombre.toLowerCase();
        final descripcion = servicio.descripcion.toLowerCase();
        final emprendedor = servicio.emprendedor.toLowerCase();
        final ubicacion = servicio.ubicacionReferencia?.toLowerCase() ?? '';
        
        return nombre.contains(searchTerm) ||
               descripcion.contains(searchTerm) ||
               emprendedor.contains(searchTerm) ||
               ubicacion.contains(searchTerm);
      }).toList();
    }
    
    setState(() {
      _filteredServicios = filtered;
    });
  }

  Future<void> _fetchServicios() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      print('🔄 Iniciando carga de servicios...');
      final serviciosData = await _servicioService.getServicios();
      print('📊 Datos recibidos: ${serviciosData.length} servicios');
      
      setState(() {
        _servicios = serviciosData.map((data) {
          print('🔧 Procesando servicio: ${data['nombre']}');
          return Servicio.fromJson(data);
        }).toList();
        _filteredServicios = List.from(_servicios);
        _loading = false;
      });
      
      print('✅ Servicios cargados exitosamente: ${_servicios.length}');
    } catch (e) {
      print('❌ Error al cargar servicios: $e');
      setState(() {
        _error = 'Error de conexión: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Explorar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar servicios...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _applySearchAndFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
                ),
              ),
              onChanged: (value) {
                // La búsqueda se maneja automáticamente por el listener
              },
            ),
            const SizedBox(height: 16),
            // Filtros horizontales
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = _selectedFilter == index;
                  return ChoiceChip(
                    label: Text(_filters[index], style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    )),
                    selected: selected,
                    selectedColor: const Color(0xFF9C27B0),
                    backgroundColor: Colors.grey[200],
                    onSelected: (_) {
                      _applyFilter(index);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Botones de organización
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFF6A1B9A), // Violeta oscuro
                  color: Colors.grey[700],
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 36),
                  isSelected: [_isGrid, !_isGrid],
                  onPressed: (index) {
                    setState(() {
                      _isGrid = index == 0;
                    });
                  },
                  children: const [
                    Icon(Icons.grid_view),
                    Icon(Icons.view_list),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Texto de resultados
            if (!_loading && _error == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${_filteredServicios.length} servicios encontrados',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9C27B0)),
                          ),
                          if (_isSearching) ...[
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_searchController.text.isNotEmpty || _selectedFilter != 0)
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            _selectedFilter = 0;
                            _applySearchAndFilter();
                          },
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Limpiar filtros'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF9C27B0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getResultsDescription(),
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            // Resultados
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : _buildServiciosList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiciosList() {
    if (_filteredServicios.isEmpty) {
      final searchTerm = _searchController.text.trim();
      final filterName = _filters[_selectedFilter];
      
      String message;
      String suggestion;
      
      if (searchTerm.isNotEmpty && filterName != 'Todos') {
        message = 'No se encontraron servicios de $filterName que coincidan con "$searchTerm"';
        suggestion = 'Intenta con otros términos de búsqueda o cambia el filtro';
      } else if (searchTerm.isNotEmpty) {
        message = 'No se encontraron servicios que coincidan con "$searchTerm"';
        suggestion = 'Intenta con otros términos de búsqueda';
      } else if (filterName != 'Todos') {
        message = 'No hay servicios disponibles en $filterName';
        suggestion = 'Prueba con otra categoría o ver todos los servicios';
      } else {
        message = 'No hay servicios disponibles';
        suggestion = 'Intenta más tarde';
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.miscellaneous_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              suggestion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (searchTerm.isNotEmpty || filterName != 'Todos')
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _selectedFilter = 0;
                  _applySearchAndFilter();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Ver todos los servicios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      );
    }
    
    if (_isGrid) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _filteredServicios.length,
        itemBuilder: (context, index) {
          final servicio = _filteredServicios[index];
          return _ServicioCard(servicio: servicio);
        },
      );
    } else {
      return ListView.separated(
        itemCount: _filteredServicios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final servicio = _filteredServicios[index];
          return _ServicioCard(servicio: servicio);
        },
      );
    }
  }

  String _getResultsDescription() {
    final filterName = _filters[_selectedFilter];
    final searchTerm = _searchController.text.trim();
    
    if (searchTerm.isNotEmpty && filterName != 'Todos') {
      return 'Mostrando servicios de $filterName que coinciden con "$searchTerm"';
    } else if (searchTerm.isNotEmpty) {
      return 'Mostrando servicios que coinciden con "$searchTerm"';
    } else if (filterName != 'Todos') {
      return 'Mostrando servicios de $filterName';
    } else {
      return 'Mostrando todos los servicios disponibles';
    }
  }
}

class _ServicioCard extends StatelessWidget {
  final Servicio servicio;
  const _ServicioCard({required this.servicio});

  String _getCategoryIcon(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('alojamiento') || cat.contains('hospedaje')) return '🏨';
    if (cat.contains('alimentacion') || cat.contains('restaurante')) return '🍽️';
    if (cat.contains('artesania') || cat.contains('artesanal')) return '🎨';
    if (cat.contains('transporte') || cat.contains('viaje')) return '🚗';
    if (cat.contains('actividad') || cat.contains('turismo')) return '🏃';
    return '🏢';
  }

  String _getCategoryName(String categoria) {
    final cat = categoria.toLowerCase();
    if (cat.contains('alojamiento') || cat.contains('hospedaje')) return 'Alojamiento';
    if (cat.contains('alimentacion') || cat.contains('restaurante')) return 'Alimentación';
    if (cat.contains('artesania') || cat.contains('artesanal')) return 'Artesanía';
    if (cat.contains('transporte') || cat.contains('viaje')) return 'Transporte';
    if (cat.contains('actividad') || cat.contains('turismo')) return 'Actividades';
    return categoria;
  }

  @override
  Widget build(BuildContext context) {
    final categoria = servicio.categorias.isNotEmpty ? servicio.categorias.first : 'General';
    final ubicacion = servicio.ubicacionReferencia ?? 'Ubicación no especificada';
    
    // Imagen del servicio (usar imagen por defecto por ahora)
    String imgUrl = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80';
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navegar a detalles del servicio
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles de ${servicio.nombre}')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imgUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 48, color: Colors.grey),
                    ),
                  ),
                ),
                // Categoría (arriba izquierda)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getCategoryIcon(categoria),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCategoryName(categoria),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Precio (arriba derecha)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'S/. ${servicio.precio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Ubicación (abajo de la imagen)
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ubicacion,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del servicio
                  Text(
                    servicio.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: Color(0xFF6A1B9A)
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Descripción
                  Text(
                    servicio.descripcion,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Emprendedor
                  Row(
                    children: [
                      const Icon(Icons.business, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          servicio.emprendedor,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Color(0xFF6A1B9A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Emprendedor local',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Disponibilidad
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Disponible:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          servicio.horariosText,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botón Ver Detalles
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar a detalles del servicio
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Detalles de ${servicio.nombre}')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ver Detalles',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 