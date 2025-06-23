import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/entrepreneur/entrepreneur_bloc.dart';
import '../../../blocs/entrepreneur/entrepreneur_event.dart';
import '../../../blocs/entrepreneur/entrepreneur_state.dart';
import '../../../widgets/entrepreneur_card.dart';
import 'emprendedor_form_screen.dart';
import '../../../models/entrepreneur.dart';

class EmprendedoresManagementScreen extends StatefulWidget {
  const EmprendedoresManagementScreen({Key? key}) : super(key: key);

  @override
  State<EmprendedoresManagementScreen> createState() => _EmprendedoresManagementScreenState();
}

class _EmprendedoresManagementScreenState extends State<EmprendedoresManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  bool _isGrid = true;
  final List<String> _filters = [
    'Todos',
    'Alojamientos',
    'Alimentación',
    'Artesanía',
    'Transporte',
    'Actividades',
  ];
  final Map<String, String> _filterToCategory = {
    'Todos': '',
    'Alojamientos': 'Alojamiento',
    'Alimentación': 'Alimentación',
    'Artesanía': 'Artesanía',
    'Transporte': 'Transporte',
    'Actividades': 'Actividades',
  };
  List<Entrepreneur> _allEntrepreneurs = [];
  List<Entrepreneur> _filteredEntrepreneurs = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearchAndFilter);
    context.read<EntrepreneurBloc>().add(LoadEntrepreneurs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearchAndFilter() {
    final searchTerm = _searchController.text.toLowerCase().trim();
    final filterName = _filters[_selectedFilter];
    final category = _filterToCategory[filterName] ?? '';
    List<Entrepreneur> filtered = _allEntrepreneurs;
    if (category.isNotEmpty) {
      filtered = filtered.where((e) => e.categoria == category).toList();
    }
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((e) {
        final nombre = (e.name).toLowerCase();
        final descripcion = (e.description ?? '').toLowerCase();
        final ubicacion = (e.location).toLowerCase();
        final categoria = (e.categoria).toLowerCase();
        final tipoServicio = (e.tipoServicio).toLowerCase();
        return nombre.contains(searchTerm) ||
            descripcion.contains(searchTerm) ||
            ubicacion.contains(searchTerm) ||
            categoria.contains(searchTerm) ||
            tipoServicio.contains(searchTerm);
      }).toList();
    }
    setState(() {
      _filteredEntrepreneurs = filtered;
    });
  }

  void _onFilterChanged(int index) {
    setState(() => _selectedFilter = index);
    _applySearchAndFilter();
  }

  void _onCreate(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmprendedorFormScreen(
          onSubmit: (data) {
            context.read<EntrepreneurBloc>().add(CreateEntrepreneur(data));
            Navigator.pop(context);
          },
        ),
      ),
    );
    context.read<EntrepreneurBloc>().add(LoadEntrepreneurs());
  }

  void _onEdit(BuildContext context, Entrepreneur emprendedor) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmprendedorFormScreen(
          initialData: emprendedor.toJson(),
          isEdit: true,
          onSubmit: (data) {
            context.read<EntrepreneurBloc>().add(UpdateEntrepreneur(emprendedor.id, data));
            Navigator.pop(context);
          },
        ),
      ),
    );
    context.read<EntrepreneurBloc>().add(LoadEntrepreneurs());
  }

  void _onDelete(BuildContext context, Entrepreneur emprendedor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este emprendedor?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      context.read<EntrepreneurBloc>().add(DeleteEntrepreneur(emprendedor.id));
      context.read<EntrepreneurBloc>().add(LoadEntrepreneurs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Emprendedores'),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar emprendedores...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9C27B0)),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _applySearchAndFilter(),
            ),
            const SizedBox(height: 16),
            // Filtros
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
                    onSelected: (_) => _onFilterChanged(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Botones de vista (cuadrícula/lista)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFF6A1B9A),
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
            const SizedBox(height: 16),
            // Lista de emprendedores
            Expanded(
              child: BlocConsumer<EntrepreneurBloc, EntrepreneurState>(
                listener: (context, state) {
                  if (state is EntrepreneurSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                    );
                  } else if (state is EntrepreneurError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is EntrepreneurLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is EntrepreneurLoaded) {
                    if (_allEntrepreneurs.isEmpty || _allEntrepreneurs.length != state.entrepreneurs.length) {
                      _allEntrepreneurs = state.entrepreneurs;
                      Future.microtask(() => _applySearchAndFilter());
                    }
                    if (_filteredEntrepreneurs.isEmpty) {
                      return const Center(child: Text('No hay emprendedores registrados.'));
                    }
                    if (_isGrid) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: _filteredEntrepreneurs.length,
                            itemBuilder: (context, index) {
                              final e = _filteredEntrepreneurs[index];
                              return EntrepreneurCard(
                                entrepreneur: e,
                                isAdmin: true,
                                showEditButton: true,
                                showDeleteButton: true,
                                onEdit: () => _onEdit(context, e),
                                onDelete: () => _onDelete(context, e),
                              );
                            },
                          );
                        },
                      );
                    } else {
                      return ListView.builder(
                        itemCount: _filteredEntrepreneurs.length,
                        itemBuilder: (context, index) {
                          final e = _filteredEntrepreneurs[index];
                          return EntrepreneurCard(
                            entrepreneur: e,
                            isAdmin: true,
                            showEditButton: true,
                            showDeleteButton: true,
                            onEdit: () => _onEdit(context, e),
                            onDelete: () => _onDelete(context, e),
                          );
                        },
                      );
                    }
                  } else if (state is EntrepreneurError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreate(context),
        backgroundColor: const Color(0xFF9C27B0),
        child: const Icon(Icons.add),
        tooltip: 'Agregar Emprendedor',
      ),
    );
  }
} 