import 'package:product_inventory/features/inventory/domain/entities/product.dart';

abstract class InventoryRepository {
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
    String? query,
    String? category,
    String? sortBy,
    bool? lowStockOnly,
  });

  Future<Product?> getProductById(String id);

  Future<void> addProduct(Product product);

  Future<void> updateProduct(Product product);

  Future<void> deleteProduct(String id);

  Future<List<String>> getCategories();
}
