import 'package:flutter/material.dart';
import 'package:product_inventory/core/theme/app_theme.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/core/utils/app_snackbar.dart';
import 'package:product_inventory/core/widgets/premium_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_event.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/products/${product.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: PremiumNetworkImage(
                    imageUrl: product.imageUrl,
                    fallbackIconSize: 32,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                context.push('/products/${product.id}/edit');
                              } else if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Product'),
                                    content: const Text('Are you sure you want to delete this product?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          context.read<InventoryBloc>().add(DeleteProductEvent(product.id));
                                          AppSnackBar.showSuccess(context, 'Product deleted successfully!');
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.star_rounded,
                              color: AppTheme.warning,
                              size: 12,
                            );
                          }),
                          SizedBox(width: 4),
                          Text(
                            '·  SKU-${product.id.substring(0, 8)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          _buildStockBadge(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStockBadge(BuildContext context) {
    final bool isLowStock = product.stock < 20;
    final Color bgColor = isLowStock
        ? AppTheme.warning.withValues(alpha: 0.1)
        : AppTheme.success.withValues(alpha: 0.1);
    final Color textColor = isLowStock ? AppTheme.warning : AppTheme.success;
    final IconData icon = isLowStock
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          SizedBox(width: 4),
          Text(
            isLowStock
                ? 'Low Stock (${product.stock})'
                : 'In Stock (${product.stock})',
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
