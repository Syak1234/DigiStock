import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryEvent extends InventoryEvent {
  final int page;
  final String? query;
  final String? category;
  final String? sortBy;
  final bool? lowStockOnly;
  final bool isRefresh;

  const LoadInventoryEvent({
    this.page = 1,
    this.query,
    this.category,
    this.sortBy,
    this.lowStockOnly,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [page, query, category, sortBy, lowStockOnly, isRefresh];
}

class LoadCategoriesEvent extends InventoryEvent {}

class LoadDashboardDataEvent extends InventoryEvent {}

class DeleteProductEvent extends InventoryEvent {
  final String id;
  const DeleteProductEvent(this.id);
  @override
  List<Object?> get props => [id];
}
