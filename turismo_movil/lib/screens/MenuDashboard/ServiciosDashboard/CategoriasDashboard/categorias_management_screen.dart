import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/categories/categories_bloc.dart';
import '../../../../blocs/categories/categories_event.dart';
import '../../../../blocs/categories/categories_state.dart';
import '../../../../services/categories_service.dart';
import '../../../../models/categoria.dart';
import 'categoria_form_screen.dart';

class CategoriasManagementScreen extends StatefulWidget {
  const CategoriasManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoriasManagementScreen> createState() => _CategoriasManagementScreenState();
}

class _CategoriasManagementScreenState extends State<CategoriasManagementScreen> {
  String _search = '';
  int? _selectedCategoriaId;

  late final CategoriesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CategoriesBloc(CategoriesService());
    _bloc.add(LoadCategories());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _abrirFormularioCrear(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CategoriaFormScreen(
          onSubmit: (nombre, descripcion, iconoUrl, imagenUrl) async {
            Navigator.of(ctx).pop();
            try {
              await CategoriesService().crearCategoria(nombre, descripcion, iconoUrl, imagenUrl);
              _bloc.add(LoadCategories());
            } catch (e) {
              print('Error al crear categoría: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al crear categoría: $e'), backgroundColor: Colors.red),
              );
            }
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _abrirFormularioEditar(BuildContext context, Categoria categoria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: CategoriaFormScreen(
          initialNombre: categoria.nombre,
          initialDescripcion: categoria.descripcion,
          initialIconoUrl: categoria.icono,
          initialImagenUrl: '',
          isEdit: true,
          onSubmit: (nombre, descripcion, iconoUrl, imagenUrl) async {
            Navigator.of(ctx).pop();
            try {
              await CategoriesService().editarCategoria(categoria.id, nombre, descripcion, iconoUrl, imagenUrl);
              _bloc.add(LoadCategories());
            } catch (e) {
              print('Error al editar categoría: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al editar categoría: $e'), backgroundColor: Colors.red),
              );
            }
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  void _eliminarCategoria(BuildContext context, Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text('¿Estás seguro de eliminar la categoría "${categoria.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await CategoriesService().eliminarCategoria(categoria.id);
        _bloc.add(LoadCategories());
      } catch (e) {
        print('Error al eliminar categoría: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar categoría: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Categorías'),
          backgroundColor: const Color(0xFF9C27B0),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _abrirFormularioCrear(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Categoría'),
          backgroundColor: const Color(0xFF9C27B0),
        ),
        body: BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoriesLoaded) {
              final categorias = state.categories;
              // Filtros
              final categoriasFiltradas = categorias.where((cat) {
                final matchSearch = _search.isEmpty ||
                  cat.nombre.toLowerCase().contains(_search.toLowerCase()) ||
                  cat.descripcion.toLowerCase().contains(_search.toLowerCase());
                final matchCategoria = _selectedCategoriaId == null || cat.id == _selectedCategoriaId;
                return matchSearch && matchCategoria;
              }).toList();
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Buscar categoría...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (value) => setState(() => _search = value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int?>(
                          value: _selectedCategoriaId,
                          hint: const Text('Filtrar'),
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('Todas')),
                            ...categorias.map((cat) => DropdownMenuItem<int?>(
                              value: cat.id,
                              child: Text(cat.nombre),
                            )),
                          ],
                          onChanged: (value) => setState(() => _selectedCategoriaId = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (categoriasFiltradas.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No hay categorías aún. Crea una nueva para comenzar.'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: categoriasFiltradas.length,
                        itemBuilder: (context, index) {
                          final categoria = categoriasFiltradas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: Icon(Icons.category, color: const Color(0xFF9C27B0)), // TODO: usar icono real
                              title: Text(categoria.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(categoria.descripcion),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _abrirFormularioEditar(context, categoria),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _eliminarCategoria(context, categoria),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            } else if (state is CategoriesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
} 