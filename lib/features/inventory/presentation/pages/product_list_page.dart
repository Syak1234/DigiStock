import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:product_inventory/features/inventory/presentation/widgets/product_card.dart';
import 'package:product_inventory/features/inventory/presentation/widgets/skeleton_loader.dart';
import 'package:product_inventory/core/widgets/premium_empty_state.dart';
import 'dart:async';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<InventoryBloc>().add(LoadCategoriesEvent());
    context.read<InventoryBloc>().add(
      const LoadInventoryEvent(isRefresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<InventoryBloc>().add(const LoadInventoryEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<InventoryBloc>().add(
        LoadInventoryEvent(
          query: query,
          isRefresh: true,
          category: context.read<InventoryBloc>().state.currentCategory,
        ),
      );
    });
  }

  void _onCategorySelected(String? category) {
    context.read<InventoryBloc>().add(
      LoadInventoryEvent(
        category: category,
        query: _searchController.text,
        isRefresh: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildBanner()),
              SliverToBoxAdapter(child: _buildSearchBar()),
            ];
          },
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<InventoryBloc>().add(
                LoadInventoryEvent(
                  isRefresh: true,
                  query: _searchController.text,
                  category: context.read<InventoryBloc>().state.currentCategory,
                ),
              );
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: _buildCategoryList(),
                  ),
                ),
                _buildSliverProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage all your products easily',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => context.push('/products/add'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 00.0, vertical: 3.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/inventory.png',
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products, SKU, category...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                final state = context.read<InventoryBloc>().state;
                _showFilterBottomSheet(context, state);
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.filter_alt_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, InventoryState state) {
    String? currentSortBy = state.sortBy;
    bool currentLowStockOnly = state.lowStockOnly;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 16.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      'Sort & Filter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortChip(
                          'Price (Low to High)',
                          'price_asc',
                          currentSortBy,
                          (val) {
                            setState(() => currentSortBy = val);
                          },
                        ),
                        _buildSortChip(
                          'Price (High to Low)',
                          'price_desc',
                          currentSortBy,
                          (val) {
                            setState(() => currentSortBy = val);
                          },
                        ),
                        _buildSortChip(
                          'Name (A-Z)',
                          'name_asc',
                          currentSortBy,
                          (val) {
                            setState(() => currentSortBy = val);
                          },
                        ),
                        _buildSortChip(
                          'Name (Z-A)',
                          'name_desc',
                          currentSortBy,
                          (val) {
                            setState(() => currentSortBy = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Low Stock Only',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Switch(
                          value: currentLowStockOnly,
                          activeThumbColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          onChanged: (val) {
                            setState(() {
                              currentLowStockOnly = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomSheetContext);
                          this.context.read<InventoryBloc>().add(
                            LoadInventoryEvent(
                              isRefresh: true,
                              sortBy: currentSortBy,
                              lowStockOnly: currentLowStockOnly,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Apply',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip(
    String label,
    String value,
    String? currentSortBy,
    Function(String?) onSelect,
  ) {
    final isSelected = currentSortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        onSelect(selected ? value : null);
      },
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      showCheckmark: false,
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.currentCategory != current.currentCategory,
      builder: (context, state) {
        if (state.categories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.categories.length + 1,
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : state.categories[index - 1];
              final isSelected = state.currentCategory == category;
              final categoryName = isAll ? 'All' : category!;

              IconData icon;
              if (isAll) {
                icon = Icons.grid_view_rounded;
              } else {
                switch (categoryName.toLowerCase()) {
                  case 'electronics':
                    icon = Icons.computer_rounded;
                    break;
                  case 'furniture':
                    icon = Icons.chair_rounded;
                    break;
                  case 'home':
                    icon = Icons.home_rounded;
                    break;
                  case 'office':
                    icon = Icons.business_center_rounded;
                    break;
                  default:
                    icon = Icons.folder_outlined;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSliverProductList() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        if (state.status == InventoryStatus.loading && state.products.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: SkeletonLoader(height: 120, width: double.infinity),
                  ),
                ),
              ),
            ),
          );
        }

        if (state.status == InventoryStatus.success && state.products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: PremiumEmptyState(
                title: 'No Products Found',
                subtitle:
                    'Try adjusting your search or filters to find what you are looking for.',
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 24.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == state.products.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final product = state.products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ProductCard(product: product),
                );
              },
              childCount: state.hasReachedMax
                  ? state.products.length
                  : state.products.length + 1,
            ),
          ),
        );
      },
    );
  }
}
