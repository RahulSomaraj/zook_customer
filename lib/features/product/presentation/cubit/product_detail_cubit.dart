import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_detail.dart';
import '../../domain/repositories/product_repository.dart';

part 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final ProductRepository repository;
  ProductDetailCubit({required this.repository})
      : super(const ProductDetailState());

  Future<void> load(String id) async {
    emit(state.copyWith(status: DetailStatus.loading));
    final result = await repository.getProductDetail(id);
    result.fold(
      (f) => emit(state.copyWith(
          status: DetailStatus.failure, errorMessage: f.message)),
      (detail) =>
          emit(state.copyWith(status: DetailStatus.loaded, detail: detail)),
    );
  }
}
