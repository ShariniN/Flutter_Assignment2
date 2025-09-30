import 'package:json_annotation/json_annotation.dart';
import 'category.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final String? description;
  @JsonKey(fromJson: _priceFromJson)
  final double price;
  @JsonKey(name: 'discount_price', fromJson: _discountPriceFromJson)
  final double? discountPrice;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final Category? category;
  final String? sku;
  final String? image;
  final Map<String, dynamic>? specifications;

  @JsonKey(name: 'is_active', fromJson: _boolFromInt)
  final bool isActive;

  @JsonKey(name: 'is_featured', fromJson: _boolFromInt)
  final bool isFeatured;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    required this.categoryId,
    this.category,
    this.sku,
    this.image,
    this.specifications,
    this.isActive = true,
    this.isFeatured = false,
  });

  static bool _boolFromInt(dynamic value) {
  try {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value.isEmpty) return false;
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  } catch (e) {
    print('Error converting to bool: $value, error: $e');
    return false;
  }
}

  static double _priceFromJson(dynamic value) {
    if (value is String) return double.parse(value);
    return (value as num).toDouble();
  }

  static double? _discountPriceFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return double.parse(value);
    return (value as num).toDouble();
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
