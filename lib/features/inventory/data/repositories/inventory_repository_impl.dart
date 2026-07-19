import 'package:product_inventory/features/inventory/data/datasources/hive_inventory_data_source.dart';
import 'package:product_inventory/features/inventory/data/models/product_model.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:product_inventory/core/error/exceptions.dart';
import 'package:product_inventory/core/error/failures.dart';
import 'package:product_inventory/core/utils/either.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final HiveInventoryDataSource dataSource;

  InventoryRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    int page = 1,
    int limit = 10,
    String? query,
    String? category,
    String? sortBy,
    bool? lowStockOnly,
  }) async {
    try {
      final models = await dataSource.getProducts(
        page: page,
        limit: limit,
        query: query,
        category: category,
        sortBy: sortBy,
        lowStockOnly: lowStockOnly,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getProductById(String id) async {
    try {
      final model = await dataSource.getProductById(id);
      return Right(model?.toEntity());
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      await dataSource.addProduct(ProductModel.fromEntity(product));
      return const Right(null);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      await dataSource.updateProduct(ProductModel.fromEntity(product));
      return const Right(null);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await dataSource.deleteProduct(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      final categories = await dataSource.getCategories();
      return Right(categories);
    } on AppException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('An unexpected error occurred: $e'));
    }
  }
}
