import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../product/domain/entities/product.dart';
import '../../../product/domain/entities/product_grade.dart';
import '../../../product/domain/repositories/product_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ProductRepository repository;
  CategoryCubit({required this.repository}) : super(const CategoryState());

  Future<void> load(String categoryId) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await repository.getByCategory(categoryId);
    result.fold(
      (f) => emit(state.copyWith(
          status: CategoryStatus.failure, errorMessage: f.message)),
      (items) => emit(
          state.copyWith(status: CategoryStatus.loaded, products: items)),
    );
  }

  void selectSubCategory(int index) =>
      emit(state.copyWith(selectedSubCategoryIndex: index));

  void selectGrade(GradeFilter grade) =>
      emit(state.copyWith(gradeFilter: grade));
}
