import 'package:hive/hive.dart';
import 'package:product_inventory/features/inventory/domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stock;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String? sku;

  @HiveField(8)
  final String? barcode;

  @HiveField(9)
  final DateTime? addedOn;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    this.sku,
    this.barcode,
    this.addedOn,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      category: product.category,
      imageUrl: product.imageUrl,
      sku: product.sku,
      barcode: product.barcode,
      addedOn: product.addedOn,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl,
      sku: sku,
      barcode: barcode,
      addedOn: addedOn,
    );
  }
}
