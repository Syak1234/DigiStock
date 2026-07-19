import 'package:equatable/equatable.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';

enum InventoryStatus { initial, loading, success, failure }

class InventoryState extends Equatable {
  final InventoryStatus status;
  final List<Product> products;
  final List<Product> allProducts;
  final List<String> categories;
  final String? errorMessage;
  final int currentPage;
  final bool hasReachedMax;
  final String? currentQuery;
  final String? currentCategory;
  final String? sortBy;
  final bool lowStockOnly;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.products = const [],
    this.allProducts = const [],
    this.categories = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.currentQuery,
    this.currentCategory,
    this.sortBy,
    this.lowStockOnly = false,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<Product>? products,
    List<Product>? allProducts,
    List<String>? categories,
    String? errorMessage,
    int? currentPage,
    bool? hasReachedMax,
    String? currentQuery,
    String? currentCategory,
    String? sortBy,
    bool? lowStockOnly,
    bool clearQuery = false,
    bool clearCategory = false,
    bool clearSortBy = false,
  }) {
    return InventoryState(
      status: status ?? this.status,
      products: products ?? this.products,
      allProducts: allProducts ?? this.allProducts,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentQuery: clearQuery ? null : (currentQuery ?? this.currentQuery),
      currentCategory: clearCategory ? null : (currentCategory ?? this.currentCategory),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        allProducts,
        categories,
        errorMessage,
        currentPage,
        hasReachedMax,
        currentQuery,
        currentCategory,
        sortBy,
        lowStockOnly,
      ];
}
