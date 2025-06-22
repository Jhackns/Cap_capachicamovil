import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';

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
    'Restaurantes',
    'Actividades',
    'Transporte',
    'Artesanías',
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmprendedores();
  }

  Future<void> _fetchEmprendedores() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final url = ApiConfig.getEntrepreneursUrl();
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final paginated = data['data'];
        if (data['success'] == true && paginated != null && paginated['data'] != null) {
          setState(() {
            _emprendedores = paginated['data'];
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
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
                      setState(() {
                        _selectedFilter = index;
                      });
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
            if (!_loading && _error == null && _selectedFilter == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_emprendedores.length} emprendimientos encontrados',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9C27B0)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mostrando todos los emprendimientos disponibles',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
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
    );
  }

  Widget _buildEmprendedoresList() {
    if (_emprendedores.isEmpty) {
      return const Center(child: Text('No hay emprendimientos disponibles.'));
    }
    if (_isGrid) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _emprendedores.length,
        itemBuilder: (context, index) {
          final e = _emprendedores[index];
          return _EmprendedorCard(emprendedor: e);
        },
      );
    } else {
      return ListView.separated(
        itemCount: _emprendedores.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = _emprendedores[index];
          return _EmprendedorCard(emprendedor: e);
        },
      );
    }
  }
}

class _EmprendedorCard extends StatelessWidget {
  final Map<String, dynamic> emprendedor;
  const _EmprendedorCard({required this.emprendedor});

  @override
  Widget build(BuildContext context) {
    final nombre = emprendedor['nombre'] ?? '';
    final descripcion = emprendedor['descripcion'] ?? '';
    final ubicacion = emprendedor['ubicacion'] ?? '';
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
        onTap: () {}, // Aquí puedes navegar al detalle
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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