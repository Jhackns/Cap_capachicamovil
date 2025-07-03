import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/categoria.dart';
import '../../services/categories_service.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesService categoriesService;
  CategoriesBloc(this.categoriesService) : super(CategoriesInitial()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoriesLoading());
      try {
        final categories = await categoriesService.getAllCategories();
        emit(CategoriesLoaded(categories));
      } catch (e) {
        emit(CategoriesError(e.toString()));
      }
    });
  }
} 