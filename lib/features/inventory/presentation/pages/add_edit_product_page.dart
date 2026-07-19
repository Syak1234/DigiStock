import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';
import 'package:product_inventory/features/inventory/domain/usecases/inventory_use_cases.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/product_form_bloc.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/product_form_event.dart';
import 'package:product_inventory/features/inventory/presentation/bloc/product_form_state.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import 'package:product_inventory/core/utils/app_snackbar.dart';
import 'package:product_inventory/core/widgets/premium_button.dart';

class AddEditProductPage extends StatelessWidget {
  final String? productId;

  const AddEditProductPage({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProductFormBloc(useCases: context.read<InventoryUseCases>()),
      child: _AddEditProductView(productId: productId),
    );
  }
}

class _AddEditProductView extends StatefulWidget {
  final String? productId;

  const _AddEditProductView({this.productId});

  @override
  State<_AddEditProductView> createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<_AddEditProductView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  Product? _existingProduct;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
    _stockController = TextEditingController();
    _categoryController = TextEditingController();
    _imageUrlController = TextEditingController();

    _loadProduct();
  }

  Future<void> _loadProduct() async {
    if (widget.productId != null) {
      final result = await context.read<InventoryUseCases>().getProductById(
        widget.productId!,
      );
      result.fold((failure) {}, (product) {
        if (product != null) {
          _existingProduct = product;
          _nameController.text = product.name;
          _descController.text = product.description;
          _priceController.text = product.price.toString();
          _stockController.text = product.stock.toString();
          _categoryController.text = product.category;
          _imageUrlController.text = product.imageUrl;
        }
      });
    }
    _isLoading.value = false;
    if (mounted) {
      context.read<ProductFormBloc>().add(
        InitializeProductForm(product: _existingProduct),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: _existingProduct?.id ?? const Uuid().v4(),
        name: _nameController.text,
        description: _descController.text,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _categoryController.text,
        imageUrl: _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageUrlController.text,
        sku:
            _existingProduct?.sku ??
            'SKU-${const Uuid().v4().substring(0, 8).toUpperCase()}',
        barcode:
            _existingProduct?.barcode ??
            const Uuid().v4().replaceAll('-', '').substring(0, 13),
        addedOn: _existingProduct?.addedOn ?? DateTime.now(),
      );

      context.read<ProductFormBloc>().add(SubmitProductForm(product));
    }
  }

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String label,
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      suffixIcon: suffixIcon,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productId != null;

    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) {
        if (isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(
              isEditing ? 'Edit Product' : 'Add Product',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: BlocConsumer<ProductFormBloc, ProductFormState>(
            listener: (context, state) {
              if (state.status == ProductFormStatus.success) {
                AppSnackBar.showSuccess(
                  context,
                  isEditing
                      ? 'Product updated successfully!'
                      : 'Product added successfully!',
                );
                context.read<InventoryBloc>().add(
                  const LoadInventoryEvent(isRefresh: true),
                );
                if (isEditing) {
                  context.go('/products/${widget.productId}');
                } else {
                  context.go('/products');
                }
              } else if (state.status == ProductFormStatus.failure) {
                AppSnackBar.showError(
                  context,
                  state.errorMessage ?? 'An error occurred',
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/inventory.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          )
                          .animate()
                          .fade(duration: 500.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: _buildInputDecoration(
                                context,
                                'Product Name',
                                'Enter product name',
                                Icons.local_offer_outlined,
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _categoryController,
                              decoration: _buildInputDecoration(
                                context,
                                'Category',
                                'Select category',
                                Icons.grid_view_rounded,
                                suffixIcon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _priceController,
                                    decoration: _buildInputDecoration(
                                      context,
                                      'Price (\$)',
                                      '0.00',
                                      Icons.monetization_on_outlined,
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    validator: (val) =>
                                        val == null ||
                                            double.tryParse(val) == null
                                        ? 'Invalid price'
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _stockController,
                                    decoration: _buildInputDecoration(
                                      context,
                                      'Stock',
                                      '0',
                                      Icons.inventory_2_outlined,
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (val) =>
                                        val == null || int.tryParse(val) == null
                                        ? 'Invalid stock'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              decoration: _buildInputDecoration(
                                context,
                                'Description',
                                'Enter product description...',
                                Icons.description_outlined,
                              ).copyWith(alignLabelWithHint: true),
                              maxLines: 3,
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _imageUrlController,
                              decoration: _buildInputDecoration(
                                context,
                                'Image URL (optional)',
                                'https://example.com/image.jpg',
                                Icons.image_outlined,
                              ),
                            ),
                            const SizedBox(height: 24),
                            PremiumButton(
                              label: isEditing ? 'Save Changes' : 'Add Product',
                              onPressed: _submit,
                              isLoading:
                                  state.status == ProductFormStatus.loading,
                              icon: isEditing
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tips',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add high quality images and accurate details for better inventory tracking.',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.stars_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 48,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
