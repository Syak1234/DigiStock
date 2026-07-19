import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryUseCases {
  final InventoryRepository repository;

  InventoryUseCases(this.repository);

  Future<List<Product>> getProducts({int page = 1, int limit = 10, String? query, String? category, String? sortBy, bool? lowStockOnly}) {
    return repository.getProducts(page: page, limit: limit, query: query, category: category, sortBy: sortBy, lowStockOnly: lowStockOnly);
  }

  Future<Product?> getProductById(String id) {
    return repository.getProductById(id);
  }

  Future<void> addProduct(Product product) {
    return repository.addProduct(product);
  }

  Future<void> updateProduct(Product product) {
    return repository.updateProduct(product);
  }

  Future<void> deleteProduct(String id) {
    return repository.deleteProduct(id);
  }

  Future<List<String>> getCategories() {
    return repository.getCategories();
  }
}
