part of 'product_detail_cubit.dart';

enum DetailStatus { initial, loading, loaded, failure }

class ProductDetailState extends Equatable {
  final DetailStatus status;
  final ProductDetail? detail;
  final String? errorMessage;

  const ProductDetailState({
    this.status = DetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    DetailStatus? status,
    ProductDetail? detail,
    String? errorMessage,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
