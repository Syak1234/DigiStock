import 'package:product_inventory/features/inventory/data/datasources/hive_inventory_data_source.dart';
import 'package:product_inventory/features/inventory/data/models/product_model.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final HiveInventoryDataSource dataSource;

  InventoryRepositoryImpl(this.dataSource);

  @override
  Future<List<Product>> getProducts({
    int page = 1,
    int limit = 10,
    String? query,
    String? category,
    String? sortBy,
    bool? lowStockOnly,
  }) async {
    final models = await dataSource.getProducts(
      page: page,
      limit: limit,
      query: query,
      category: category,
      sortBy: sortBy,
      lowStockOnly: lowStockOnly,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Product?> getProductById(String id) async {
    final model = await dataSource.getProductById(id);
    return model?.toEntity();
  }

  @override
  Future<void> addProduct(Product product) async {
    await dataSource.addProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> updateProduct(Product product) async {
    await dataSource.updateProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> deleteProduct(String id) async {
    await dataSource.deleteProduct(id);
  }

  @override
  Future<List<String>> getCategories() async {
    return await dataSource.getCategories();
  }
}
