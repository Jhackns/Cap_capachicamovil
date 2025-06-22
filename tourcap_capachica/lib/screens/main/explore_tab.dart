import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../models/review.dart';
import '../../widgets/reviews_section.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';

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
      final url = ApiConfig.getEntrepreneurByIdUrl(widget.emprendedorId);
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
      final reviewsUrl = ApiConfig.baseUrl + ApiConfig.apiPrefix + '/resenas/emprendedor/${widget.emprendedorId}';
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

  Future<void> _submitReview(String comentario, int puntuacion) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) return;

    final token = authProvider.token;
    final url = '${ApiConfig.baseUrl}${ApiConfig.apiPrefix}/resenas';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enviando reseña...')),
    );

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'emprendedor_id': widget.emprendedorId,
          'comentario': comentario,
          'puntuacion': puntuacion,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña enviada para aprobación.'), backgroundColor: Colors.green),
        );
        _fetchDetails(); // Refresh details
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['message'] ?? 'No se pudo enviar la reseña.'}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
      );
    }
  }
  
  void _showReviewForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final comentarioController = TextEditingController();
    int puntuacion = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Escribe tu reseña', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: comentarioController,
                    decoration: const InputDecoration(
                      labelText: 'Tu comentario',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu comentario';
                      }
                      if (value.length < 10) {
                        return 'El comentario debe tener al menos 10 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Puntuación: '),
                      ...List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < puntuacion ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              puntuacion = index + 1;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Navigator.of(ctx).pop(); // Close bottom sheet
                        _submitReview(comentarioController.text, puntuacion);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Enviar Reseña'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
} 