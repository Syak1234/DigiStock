import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:product_inventory/core/widgets/premium_network_image.dart';
import 'package:product_inventory/core/widgets/premium_icon_button.dart';
import 'package:product_inventory/core/utils/app_snackbar.dart';
import 'package:product_inventory/core/widgets/premium_card.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: context.read<InventoryBloc>().useCases.getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Product not found.')),
          );
        }

        final product = snapshot.data!;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        final formattedAddedOn = product.addedOn != null 
            ? '${_getMonth(product.addedOn!.month)} ${product.addedOn!.day}, ${product.addedOn!.year}'
            : 'Unknown';

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      PremiumIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                        backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                        hasShadow: false,
                        size: 38,
                        iconSize: 18,
                        borderRadius: 999,
                      ),
                      // Title
                      Expanded(
                        child: Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Action Buttons
                      Row(
                        children: [
                          PremiumIconButton(
                            icon: Icons.edit_outlined,
                            onTap: () => context.go('/products/$productId/edit'),
                            backgroundColor: colorScheme.onSurface.withValues(alpha: 0.05),
                            hasShadow: false,
                            size: 38,
                            iconSize: 18,
                            borderRadius: 999,
                          ),
                          const SizedBox(width: 8),
                          PremiumIconButton(
                            icon: Icons.delete_outline_rounded,
                            onTap: () => _confirmDelete(context, product),
                            iconColor: colorScheme.error,
                            backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                            hasShadow: false,
                            size: 38,
                            iconSize: 18,
                            borderRadius: 999,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Container with 1/5 Badge
                        Stack(
                          children: [
                            Container(
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: PremiumNetworkImage(
                                imageUrl: product.imageUrl,
                                fallbackIconSize: 64,
                              ),
                            ),
                          ],
                        ).animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                        
                        const SizedBox(height: 24),
                        
                        // Title and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ).animate().fade(delay: 100.ms).slideY(begin: 0.1, end: 0),
                        
                        const SizedBox(height: 12),
                        
                        // Category Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.laptop_chromebook_outlined,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 200.ms).slideY(begin: 0.1, end: 0),
                        
                        const SizedBox(height: 24),
                        
                        // Description Card
                        PremiumCard(
                          backgroundColor: colorScheme.surface,
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(delay: 300.ms).slideY(begin: 0.1, end: 0),
                        
                        const SizedBox(height: 16),
                        
                        // Inventory Level Card
                        _buildInventoryCard(context, product, colorScheme)
                            .animate().fade(delay: 400.ms).slideY(begin: 0.1, end: 0),
                            
                        const SizedBox(height: 16),
                        
                        // Product Details Card
                        _buildProductDetailsCard(context, product, formattedAddedOn, colorScheme)
                            .animate().fade(delay: 500.ms).slideY(begin: 0.1, end: 0),
                            
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildInventoryCard(BuildContext context, Product product, ColorScheme colorScheme) {
    final bool isLowStock = product.stock < 20;
    final bool isOutOfStock = product.stock == 0;
    
    Color statusColor = const Color(0xFF22C55E); // Success green (as per rule #10 success color)
    String statusText = 'In Stock';
    
    if (isOutOfStock) {
      statusColor = colorScheme.error;
      statusText = 'Out of Stock';
    } else if (isLowStock) {
      statusColor = const Color(0xFFF59E0B); // Warning color (as per rule #10 warning color)
      statusText = 'Low Stock';
    }

    return PremiumCard(
      backgroundColor: colorScheme.primary.withValues(alpha: 0.03),
      hasShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Level',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.stock} units available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsCard(BuildContext context, Product product, String formattedAddedOn, ColorScheme colorScheme) {
    return PremiumCard(
      backgroundColor: colorScheme.surface,
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
      hasShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.sell_outlined, 'Category', product.category, colorScheme, isPrimary: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          _buildDetailRow(Icons.tag_rounded, 'SKU', product.sku ?? 'N/A', colorScheme),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          _buildDetailRow(Icons.qr_code_scanner_rounded, 'Barcode', product.barcode ?? 'N/A', colorScheme),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          _buildDetailRow(Icons.calendar_today_outlined, 'Added On', formattedAddedOn, colorScheme),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value, ColorScheme colorScheme, {bool isPrimary = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPrimary ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Delete Product?', style: TextStyle(color: colorScheme.onSurface)),
        content: Text('Are you sure you want to delete ${product.name}?', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface)),
          ),
          TextButton(
            onPressed: () {
              context.read<InventoryBloc>().add(DeleteProductEvent(product.id));
              Navigator.of(ctx).pop();
              context.go('/products');
              AppSnackBar.showSuccess(context, 'Product deleted successfully!');
            },
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
