import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/api_config.dart';
import '../../models/review.dart';
import '../../widgets/reviews_section.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  bool _isGrid = true;
  List<dynamic> _emprendedores = [];
  bool _loading = true;
  String? _error;

  final List<String> _filters = [
    'All',
    'Alojamientos',
    'Alimentación',
    'Artesanía',
    'Transporte',
    'Actividades',
  ];

  // Mapeo de filtros a categorías del backend
  final Map<String, String> _filterToCategory = {
    'All': '',
    'Alojamientos': 'Alojamiento',
    'Alimentación': 'Alimentación',
    'Artesanía': 'Artesanía',
    'Transporte': 'Transporte',
    'Actividades': 'Actividades',
  };

  List<dynamic> _filteredEmprendedores = [];
  Timer? _searchTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchEmprendedores();
    
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
    
    List<dynamic> filtered = _emprendedores;
    
    // Aplicar filtro de categoría
    if (category.isNotEmpty) {
      filtered = filtered.where((emprendedor) {
        final emprendedorCategoria = emprendedor['categoria']?.toString() ?? '';
        return emprendedorCategoria == category;
      }).toList();
    }
    
    // Aplicar búsqueda
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((emprendedor) {
        final nombre = (emprendedor['nombre']?.toString() ?? '').toLowerCase();
        final descripcion = (emprendedor['descripcion']?.toString() ?? '').toLowerCase();
        final ubicacion = (emprendedor['ubicacion']?.toString() ?? '').toLowerCase();
        final categoria = (emprendedor['categoria']?.toString() ?? '').toLowerCase();
        final tipoServicio = (emprendedor['tipo_servicio']?.toString() ?? '').toLowerCase();
        
        return nombre.contains(searchTerm) ||
               descripcion.contains(searchTerm) ||
               ubicacion.contains(searchTerm) ||
               categoria.contains(searchTerm) ||
               tipoServicio.contains(searchTerm);
      }).toList();
    }
    
    setState(() {
      _filteredEmprendedores = filtered;
    });
  }

  Future<void> _fetchEmprendedores() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = ApiConfig.getEmprendedoresUrl();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paginated = data['data'];
        if (data['success'] == true && paginated != null && paginated['data'] != null) {
          setState(() {
            _emprendedores = paginated['data'];
            _filteredEmprendedores = List.from(_emprendedores);
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'No se encontraron emprendimientos.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Error al obtener los datos (${response.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                hintText: 'Buscar emprendimientos...',
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
                            '${_filteredEmprendedores.length} emprendimientos encontrados',
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
                      : _buildEmprendedoresList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authProvider.isAuthenticated) {
            _showReviewForm(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Debes iniciar sesión para dejar una reseña.'),
                action: SnackBarAction(
                  label: 'INICIAR SESIÓN',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Escribir Reseña'),
        backgroundColor: const Color(0xFF9C27B0),
        heroTag: 'explore_review_fab',
      ),
    );
  }

  Widget _buildEmprendedoresList() {
    if (_filteredEmprendedores.isEmpty) {
      final searchTerm = _searchController.text.trim();
      final filterName = _filters[_selectedFilter];
      
      String message;
      String suggestion;
      
      if (searchTerm.isNotEmpty && filterName != 'All') {
        message = 'No se encontraron emprendimientos de $filterName que coincidan con "$searchTerm"';
        suggestion = 'Intenta con otros términos de búsqueda o cambia el filtro';
      } else if (searchTerm.isNotEmpty) {
        message = 'No se encontraron emprendimientos que coincidan con "$searchTerm"';
        suggestion = 'Intenta con otros términos de búsqueda';
      } else if (filterName != 'All') {
        message = 'No hay emprendimientos disponibles en $filterName';
        suggestion = 'Prueba con otra categoría o ver todos los emprendimientos';
      } else {
        message = 'No hay emprendimientos disponibles';
        suggestion = 'Intenta más tarde';
      }
      
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
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
            if (searchTerm.isNotEmpty || filterName != 'All')
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _selectedFilter = 0;
                  _applySearchAndFilter();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Ver todos los emprendimientos'),
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
        itemCount: _filteredEmprendedores.length,
        itemBuilder: (context, index) {
          final e = _filteredEmprendedores[index];
          return _EmprendedorCard(emprendedor: e);
        },
      );
    } else {
      return ListView.separated(
        itemCount: _filteredEmprendedores.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = _filteredEmprendedores[index];
          return _EmprendedorCard(emprendedor: e);
        },
      );
    }
  }

  String _getResultsDescription() {
    final filterName = _filters[_selectedFilter];
    final searchTerm = _searchController.text.trim();
    
    if (searchTerm.isNotEmpty && filterName != 'All') {
      return 'Mostrando emprendimientos de $filterName que coinciden con "$searchTerm"';
    } else if (searchTerm.isNotEmpty) {
      return 'Mostrando emprendimientos que coinciden con "$searchTerm"';
    } else if (filterName != 'All') {
      return 'Mostrando emprendimientos de $filterName';
    } else {
      return 'Mostrando todos los emprendimientos disponibles';
    }
  }

  void _showReviewForm(BuildContext context) {
    // ... implementación ...
  }
}

class _EmprendedorCard extends StatelessWidget {
  final Map<String, dynamic> emprendedor;
  const _EmprendedorCard({required this.emprendedor});

  String _getCategoryIcon(String? categoria) {
    if (categoria == null) return '🏢';
    
    final cat = categoria.toLowerCase();
    if (cat.contains('alojamiento') || cat.contains('hospedaje')) return '🏨';
    if (cat.contains('alimentacion') || cat.contains('restaurante')) return '🍽️';
    if (cat.contains('artesania') || cat.contains('artesanal')) return '🎨';
    if (cat.contains('transporte') || cat.contains('viaje')) return '🚗';
    if (cat.contains('actividad') || cat.contains('turismo')) return '🏃';
    return '🏢';
  }

  String _getCategoryName(String? categoria) {
    if (categoria == null) return 'General';
    
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
    final nombre = emprendedor['nombre'] ?? '';
    final descripcion = emprendedor['descripcion'] ?? '';
    final ubicacion = emprendedor['ubicacion'] ?? '';
    final categoria = emprendedor['categoria'] ?? '';
    final estado = emprendedor['estado'] == true ? 'Activo' : 'Inactivo';
    
    List<dynamic> imagenes = [];
    try {
      if (emprendedor['imagenes'] != null && emprendedor['imagenes'] is String) {
        imagenes = json.decode(emprendedor['imagenes']);
      } else if (emprendedor['imagenes'] is List) {
        imagenes = emprendedor['imagenes'];
      }
    } catch (_) {}
    
    String imgUrl = '';
    if (imagenes.isNotEmpty && imagenes[0] is String) {
      final img = imagenes[0] as String;
      if (img.startsWith('http')) {
        imgUrl = img;
      } else {
        imgUrl = 'http://192.168.1.64:8000/storage/$img';
      }
    } else {
      imgUrl = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80';
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EmprendedorDetailScreen(emprendedorId: emprendedor['id']),
            ),
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
                Positioned(
                  top: 8,
                  right: 8,
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
                if (estado == 'Inactivo')
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Inactivo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
                  Text(
                    nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6A1B9A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class EmprendedorDetailScreen extends StatefulWidget {
  final int emprendedorId;
  const EmprendedorDetailScreen({Key? key, required this.emprendedorId}) : super(key: key);

  @override
  State<EmprendedorDetailScreen> createState() => _EmprendedorDetailScreenState();
}

class _EmprendedorDetailScreenState extends State<EmprendedorDetailScreen> {
  Map<String, dynamic>? _emprendedor;
  List<dynamic> _imagenes = [];
  List<Review> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Fetch emprendedor details
      final url = ApiConfig.getEmprendedorByIdUrl(widget.emprendedorId);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _emprendedor = data['data'];
          // Parse images
          if (_emprendedor!['imagenes'] != null && _emprendedor!['imagenes'] is String) {
            _imagenes = json.decode(_emprendedor!['imagenes']);
          } else if (_emprendedor!['imagenes'] is List) {
            _imagenes = _emprendedor!['imagenes'];
          }
        } else {
          setState(() {
            _error = 'No se encontró el emprendimiento.';
            _loading = false;
          });
          return;
        }
      } else {
        setState(() {
          _error = 'Error al obtener los datos (${response.statusCode})';
          _loading = false;
        });
        return;
      }
      // Fetch reviews
      final reviewsUrl = ApiConfig.baseUrl + '/api/resenas/emprendedor/${widget.emprendedorId}';
      final reviewsResponse = await http.get(Uri.parse(reviewsUrl));
      if (reviewsResponse.statusCode == 200) {
        final rdata = json.decode(reviewsResponse.body);
        if (rdata['success'] == true && rdata['data'] != null) {
          _reviews = (rdata['data'] as List).map((e) => Review.fromJson(e)).toList();
        }
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _loading = false;
      });
    }
  }

  Future<void> _submitReview(String comentario, int puntuacion, List<File> imagenes) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Debug logging
    print('=== DEBUG REVIEW SUBMISSION ===');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('Token: ${authProvider.token}');
    print('Token length: ${authProvider.token?.length}');
    
    if (!authProvider.isAuthenticated) {
      print('ERROR: User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para dejar una reseña.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (authProvider.token == null || authProvider.token!.isEmpty) {
      print('ERROR: Token is null or empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de autenticación: Token no válido.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final token = authProvider.token;
    final url = '${ApiConfig.baseUrl}/api/resenas';
    
    print('URL: $url');
    print('Token being sent: $token');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando reseña...')),
    );

    try {
      // Crear request multipart para enviar imágenes
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Agregar headers de autenticación
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      print('Headers being sent: ${request.headers}');
      
      // Agregar campos de texto
      request.fields['emprendedor_id'] = widget.emprendedorId.toString();
      request.fields['comentario'] = comentario;
      request.fields['puntuacion'] = puntuacion.toString();
      
      print('Fields being sent: ${request.fields}');
      
      // Agregar imágenes si las hay
      for (int i = 0; i < imagenes.length; i++) {
        final file = imagenes[i];
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'imagenes[]',
          stream,
          length,
          filename: 'imagen_$i.jpg',
        );
        request.files.add(multipartFile);
      }

      print('Sending request...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      print('Response status: ${response.statusCode}');
      print('Response body: $responseData');
      
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 201 && jsonResponse['success'] == true) {
        print('SUCCESS: Review submitted successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reseña enviada para aprobación.'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchDetails(); // Refresh details
      } else {
        print('ERROR: Failed to submit review');
        print('Status code: ${response.statusCode}');
        print('Response: $jsonResponse');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${jsonResponse['message'] ?? 'No se pudo enviar la reseña.'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('EXCEPTION: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _testAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('=== TESTING AUTHENTICATION ===');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('Token: ${authProvider.token}');
    print('Token length: ${authProvider.token?.length}');
    print('Current user: ${authProvider.currentUser?.name}');
    print('Is admin: ${authProvider.isAdmin}');
    
    if (!authProvider.isAuthenticated || authProvider.token == null) {
      print('ERROR: Not authenticated or no token');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No estás autenticado o no tienes token válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Verificar el token directamente desde el storage
    try {
      final authService = AuthService();
      final storedToken = await authService.getToken();
      print('Token from storage: $storedToken');
      print('Token from storage length: ${storedToken?.length}');
      
      if (storedToken != authProvider.token) {
        print('WARNING: Token mismatch between provider and storage!');
        print('Provider token: ${authProvider.token}');
        print('Storage token: $storedToken');
      }
    } catch (e) {
      print('Error getting token from storage: $e');
    }
    
    // Probar primero el endpoint de perfil (que debería funcionar)
    try {
      final profileUrl = '${ApiConfig.baseUrl}/api/profile';
      print('Testing profile URL: $profileUrl');
      
      final profileHeaders = {
        'Authorization': 'Bearer ${authProvider.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      print('Profile headers being sent: $profileHeaders');
      
      final profileResponse = await http.get(
        Uri.parse(profileUrl),
        headers: profileHeaders,
      );
      
      print('Profile response status: ${profileResponse.statusCode}');
      print('Profile response body: ${profileResponse.body}');
      
      if (profileResponse.statusCode == 200) {
        print('SUCCESS: Profile endpoint works!');
      } else {
        print('ERROR: Profile endpoint failed');
      }
    } catch (e) {
      print('EXCEPTION in profile test: $e');
    }
    
    // Ahora probar el endpoint de test-auth
    try {
      final url = '${ApiConfig.baseUrl}/api/test-auth';
      print('Testing URL: $url');
      
      final headers = {
        'Authorization': 'Bearer ${authProvider.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      print('Headers being sent: $headers');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('Test auth response status: ${response.statusCode}');
      print('Test auth response headers: ${response.headers}');
      print('Test auth response body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('SUCCESS: Authentication test passed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autenticación funcionando correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('ERROR: Authentication test failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de autenticación: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('EXCEPTION in auth test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en prueba de autenticación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshAuthState() async {
    print('=== REFRESHING AUTH STATE ===');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Forzar recarga del estado de autenticación
    await authProvider.checkAuthStatus();
    
    print('After refresh:');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('Token: ${authProvider.token}');
    print('Token length: ${authProvider.token?.length}');
    print('Current user: ${authProvider.currentUser?.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estado de autenticación actualizado'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _testReviewCreation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    print('=== TESTING REVIEW CREATION ===');
    print('Is authenticated: ${authProvider.isAuthenticated}');
    print('Token: ${authProvider.token}');
    
    if (!authProvider.isAuthenticated || authProvider.token == null) {
      print('ERROR: Not authenticated or no token');
      return;
    }
    
    try {
      final url = '${ApiConfig.baseUrl}/api/resenas';
      print('Testing review creation URL: $url');
      
      final headers = {
        'Authorization': 'Bearer ${authProvider.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      
      print('Review headers being sent: $headers');
      
      // Crear datos de prueba para la reseña
      final testData = {
        'emprendedor_id': widget.emprendedorId,
        'comentario': 'Esta es una reseña de prueba para verificar la autenticación.',
        'puntuacion': 5,
      };
      
      print('Review data being sent: $testData');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(testData),
      );
      
      print('Review creation response status: ${response.statusCode}');
      print('Review creation response headers: ${response.headers}');
      print('Review creation response body: ${response.body}');
      
      if (response.statusCode == 201) {
        print('SUCCESS: Review creation test passed');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Creación de reseña funcionando correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print('ERROR: Review creation test failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en creación de reseña: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('EXCEPTION in review creation test: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en prueba de creación de reseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authProvider.isAuthenticated) {
            _showReviewForm(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Debes iniciar sesión para dejar una reseña.'),
                action: SnackBarAction(
                  label: 'INICIAR SESIÓN',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
              ),
            );
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Escribir Reseña'),
        backgroundColor: const Color(0xFF9C27B0),
        heroTag: 'explore_review_fab',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final nombre = _emprendedor?['nombre'] ?? '';
    final descripcion = _emprendedor?['descripcion'] ?? '';
    final ubicacion = _emprendedor?['ubicacion'] ?? '';
    final telefono = _emprendedor?['telefono'] ?? '';
    final email = _emprendedor?['email'] ?? '';
    final horario = _emprendedor?['horario_atencion'] ?? '';
    final precio = _emprendedor?['precio_rango'] ?? '';
    final categoria = _emprendedor?['categoria'] ?? '';
    final tipoServicio = _emprendedor?['tipo_servicio'] ?? '';
    final estado = _emprendedor?['estado'] == true ? 'Activo' : 'Inactivo';
    String imgUrl = '';
    if (_imagenes.isNotEmpty && _imagenes[0] is String) {
      final img = _imagenes[0] as String;
      if (img.startsWith('http')) {
        imgUrl = img;
      } else {
        imgUrl = 'http://192.168.1.64:8000/storage/$img';
      }
    } else {
      imgUrl = 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80';
    }
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                const SizedBox(height: 8),
                Text(tipoServicio, style: const TextStyle(fontSize: 16, color: Color(0xFF9C27B0), fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(descripcion, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                _infoRow(Icons.location_on, ubicacion),
                _infoRow(Icons.phone, telefono),
                _infoRow(Icons.email, email),
                _infoRow(Icons.access_time, horario),
                _infoRow(Icons.attach_money, precio),
                _infoRow(Icons.category, categoria),
                _infoRow(Icons.verified, estado),
                const SizedBox(height: 24),
                if (_imagenes.length > 1)
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imagenes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final img = _imagenes[idx];
                        String url = '';
                        if (img is String && img.startsWith('http')) {
                          url = img;
                        } else if (img is String) {
                          url = 'http://192.168.1.64:8000/storage/$img';
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 120,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 120,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 40, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 32),
                Text('Reseñas', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
                const SizedBox(height: 8),
                _reviews.isEmpty
                    ? const Text('No hay reseñas para este emprendimiento.')
                    : ReviewsSection(reviews: _reviews),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.purple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text, 
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewForm(BuildContext context) {
    // ... implementación ...
  }
} 