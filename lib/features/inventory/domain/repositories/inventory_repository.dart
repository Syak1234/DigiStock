import 'package:product_inventory/features/inventory/domain/entities/product.dart';

import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 10,
    String? query,
    String? category,
    String? sortBy,
    bool? lowStockOnly,
  });

  Future<Either<Failure, Product?>> getProductById(String id);

  Future<Either<Failure, void>> addProduct(Product product);

  Future<Either<Failure, void>> updateProduct(Product product);

  Future<Either<Failure, void>> deleteProduct(String id);

  Future<Either<Failure, List<String>>> getCategories();
}
