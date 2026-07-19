import 'package:equatable/equatable.dart';

enum ProductFormStatus { initial, loading, success, failure }

class ProductFormState extends Equatable {
  final ProductFormStatus status;
  final String? errorMessage;
  final bool isEditing;

  const ProductFormState({
    this.status = ProductFormStatus.initial,
    this.errorMessage,
    this.isEditing = false,
  });

  ProductFormState copyWith({
    ProductFormStatus? status,
    String? errorMessage,
    bool? isEditing,
  }) {
    return ProductFormState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isEditing];
}
