import 'package:equatable/equatable.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';

abstract class ProductFormEvent extends Equatable {
  const ProductFormEvent();

  @override
  List<Object?> get props => [];
}

class InitializeProductForm extends ProductFormEvent {
  final Product? product;
  const InitializeProductForm({this.product});
  
  @override
  List<Object?> get props => [product];
}

class SubmitProductForm extends ProductFormEvent {
  final Product product;
  const SubmitProductForm(this.product);

  @override
  List<Object?> get props => [product];
}
