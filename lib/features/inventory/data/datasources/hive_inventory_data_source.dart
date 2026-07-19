import 'package:hive/hive.dart';
import 'package:product_inventory/features/inventory/data/models/product_model.dart';
import 'package:uuid/uuid.dart';

class HiveInventoryDataSource {
  static const String boxName = 'products_box';
  final Box<ProductModel> productBox;

  HiveInventoryDataSource(this.productBox);

  Future<void> init() async {
    // Check if box has old placeholder images and clear them
    if (productBox.isNotEmpty) {
      final firstProduct = productBox.values.first;
      if (firstProduct.imageUrl.contains('via.placeholder.com')) {
        await productBox.clear();
      }
    }

    if (productBox.isEmpty) {
      // Seed data with high quality unsplash images
      final now = DateTime.now();
      final initialProducts = [
        ProductModel(id: const Uuid().v4(), name: 'MacBook Pro 16"', description: 'High performance laptop for professionals.', price: 2499.0, stock: 15, category: 'Electronics', imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000&auto=format&fit=crop', sku: 'MBP16-2024', barcode: '8901234567890', addedOn: now),
        ProductModel(id: const Uuid().v4(), name: 'Logitech MX Master 3', description: 'Ergonomic wireless mouse with fast scrolling.', price: 99.0, stock: 50, category: 'Electronics', imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=1000&auto=format&fit=crop', sku: 'MXM3-2023', barcode: '8901234567891', addedOn: now.subtract(const Duration(days: 5))),
        ProductModel(id: const Uuid().v4(), name: 'Keychron K2', description: 'RGB Mechanical keyboard with tactile switches.', price: 79.0, stock: 30, category: 'Electronics', imageUrl: 'https://images.unsplash.com/photo-1595225476474-87563907a212?q=80&w=1000&auto=format&fit=crop', sku: 'KK2-RGB', barcode: '8901234567892', addedOn: now.subtract(const Duration(days: 10))),
        ProductModel(id: const Uuid().v4(), name: 'Artisan Coffee Mug', description: 'Handcrafted ceramic coffee mug, 12oz.', price: 18.0, stock: 100, category: 'Home', imageUrl: 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?q=80&w=1000&auto=format&fit=crop', sku: 'ACM-12OZ', barcode: '8901234567893', addedOn: now.subtract(const Duration(days: 2))),
        ProductModel(id: const Uuid().v4(), name: 'Herman Miller Aeron', description: 'Ergonomic mesh desk chair for long hours.', price: 1200.0, stock: 10, category: 'Furniture', imageUrl: 'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?q=80&w=1000&auto=format&fit=crop', sku: 'HMA-CHAIR', barcode: '8901234567894', addedOn: now.subtract(const Duration(days: 45))),
        ProductModel(id: const Uuid().v4(), name: 'Moleskine Classic', description: 'Ruled notebook 200 pages, hard cover.', price: 22.0, stock: 200, category: 'Stationery', imageUrl: 'https://images.unsplash.com/photo-1531346878377-a541e4ab04ce?q=80&w=1000&auto=format&fit=crop', sku: 'M-CLASSIC', barcode: '8901234567895', addedOn: now.subtract(const Duration(days: 60))),
        ProductModel(id: const Uuid().v4(), name: 'Pilot G2 Pens', description: 'Pack of 12 premium gel roller pens.', price: 14.0, stock: 150, category: 'Stationery', imageUrl: 'https://images.unsplash.com/photo-1585336261022-680e295ce3fe?q=80&w=1000&auto=format&fit=crop', sku: 'P-G2-12', barcode: '8901234567896', addedOn: now.subtract(const Duration(days: 1))),
        ProductModel(id: const Uuid().v4(), name: 'Dell UltraSharp 27"', description: '4K USB-C Hub Monitor for creatives.', price: 550.0, stock: 20, category: 'Electronics', imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d4aff?q=80&w=1000&auto=format&fit=crop', sku: 'DELL-U27', barcode: '8901234567897', addedOn: now.subtract(const Duration(days: 12))),
        ProductModel(id: const Uuid().v4(), name: 'Yeti Rambler', description: 'Insulated water bottle, stainless steel.', price: 35.0, stock: 80, category: 'Home', imageUrl: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?q=80&w=1000&auto=format&fit=crop', sku: 'YETI-R', barcode: '8901234567898', addedOn: now.subtract(const Duration(days: 25))),
        ProductModel(id: const Uuid().v4(), name: 'Jarvis Standing Desk', description: 'Bamboo adjustable standing desk.', price: 650.0, stock: 5, category: 'Furniture', imageUrl: 'https://images.unsplash.com/photo-1595515106969-1ce29566ff1c?q=80&w=1000&auto=format&fit=crop', sku: 'JARV-SD', barcode: '8901234567899', addedOn: now.subtract(const Duration(days: 3))),
      ];

      for (var product in initialProducts) {
        await productBox.put(product.id, product);
      }
    }
  }

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10, String? query, String? category, String? sortBy, bool? lowStockOnly}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    var allProducts = productBox.values.toList();

    if (query != null && query.isNotEmpty) {
      allProducts = allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }

    if (category != null && category.isNotEmpty) {
      allProducts = allProducts.where((p) => p.category == category).toList();
    }

    if (lowStockOnly == true) {
      allProducts = allProducts.where((p) => p.stock < 20).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'price_asc':
          allProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_desc':
          allProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'name_asc':
          allProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          allProducts.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= allProducts.length) {
      return [];
    }

    final endIndex = (startIndex + limit) > allProducts.length ? allProducts.length : (startIndex + limit);
    return allProducts.sublist(startIndex, endIndex);
  }

  Future<ProductModel?> getProductById(String id) async {
    return productBox.get(id);
  }

  Future<void> addProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  Future<void> updateProduct(ProductModel product) async {
    await productBox.put(product.id, product);
  }

  Future<void> deleteProduct(String id) async {
    await productBox.delete(id);
  }

  Future<List<String>> getCategories() async {
    final categories = productBox.values.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }
}
