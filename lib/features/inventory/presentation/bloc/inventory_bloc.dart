import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryUseCases useCases;
  static const int _limit = 10;

  InventoryBloc({required this.useCases}) : super(const InventoryState()) {
    on<LoadInventoryEvent>(_onLoadInventory);
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadInventory(LoadInventoryEvent event, Emitter<InventoryState> emit) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: InventoryStatus.loading,
        currentPage: 1,
        products: [],
        hasReachedMax: false,
        currentQuery: event.query,
        currentCategory: event.category,
        sortBy: event.sortBy,
        lowStockOnly: event.lowStockOnly ?? state.lowStockOnly,
        clearQuery: event.query == null,
        clearCategory: event.category == null,
        clearSortBy: event.sortBy == null,
      ));
    } else {
      if (state.hasReachedMax) return;
      if (state.status == InventoryStatus.initial) {
        emit(state.copyWith(status: InventoryStatus.loading));
      }
    }

    final page = event.isRefresh ? 1 : state.currentPage;
    
    final result = await useCases.getProducts(
      page: page,
      limit: _limit,
      query: state.currentQuery,
      category: state.currentCategory,
      sortBy: state.sortBy,
      lowStockOnly: state.lowStockOnly,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: InventoryStatus.failure, errorMessage: failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(state.copyWith(hasReachedMax: true, status: InventoryStatus.success));
        } else {
          emit(state.copyWith(
            status: InventoryStatus.success,
            products: List.of(state.products)..addAll(products),
            hasReachedMax: products.length < _limit,
            currentPage: page + 1,
          ));
        }
      }
    );
  }

  Future<void> _onLoadDashboardData(LoadDashboardDataEvent event, Emitter<InventoryState> emit) async {
    final result = await useCases.getProducts(page: 1, limit: 100000);
    result.fold(
      (failure) => null,
      (products) => emit(state.copyWith(allProducts: products))
    );
  }

  Future<void> _onLoadCategories(LoadCategoriesEvent event, Emitter<InventoryState> emit) async {
    final result = await useCases.getCategories();
    result.fold(
      (failure) => null,
      (categories) => emit(state.copyWith(categories: categories))
    );
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<InventoryState> emit) async {
    final result = await useCases.deleteProduct(event.id);
    result.fold(
      (failure) => emit(state.copyWith(status: InventoryStatus.failure, errorMessage: failure.message)),
      (_) {
        add(const LoadInventoryEvent(isRefresh: true));
        add(LoadDashboardDataEvent());
      }
    );
  }
}
