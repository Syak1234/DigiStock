import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/domain/repositories/inventory_repository.dart';

import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

class InventoryUseCases {
  final InventoryRepository repository;

  InventoryUseCases(this.repository);

  Future<Either<Failure, List<Product>>> getProducts({int page = 1, int limit = 10, String? query, String? category, String? sortBy, bool? lowStockOnly}) {
    return repository.getProducts(page: page, limit: limit, query: query, category: category, sortBy: sortBy, lowStockOnly: lowStockOnly);
  }

  Future<Either<Failure, Product?>> getProductById(String id) {
    return repository.getProductById(id);
  }

  Future<Either<Failure, void>> addProduct(Product product) {
    return repository.addProduct(product);
  }

  Future<Either<Failure, void>> updateProduct(Product product) {
    return repository.updateProduct(product);
  }

  Future<Either<Failure, void>> deleteProduct(String id) {
    return repository.deleteProduct(id);
  }

  Future<Either<Failure, List<String>>> getCategories() {
    return repository.getCategories();
  }
}
