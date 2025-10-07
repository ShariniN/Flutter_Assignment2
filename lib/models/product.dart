import 'package:json_annotation/json_annotation.dart';
import 'category.dart';
import 'dart:convert';

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
  
  @JsonKey(name: 'brand_id')
  final int? brandId;
  
  @JsonKey(name: 'brand_name')
  final String? brandName;
  
  final String? sku;

  @JsonKey(name: 'image_url')
  final String? image;

  @JsonKey(fromJson: _specificationsFromJson)
  final Map<String, dynamic>? specifications;

  @JsonKey(fromJson: _reviewsFromJson)
  final List<Map<String, dynamic>> reviews;

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
    this.brandId,
    this.brandName,
    this.sku,
    this.image,
    this.specifications,
    this.reviews = const [],
    this.isActive = true,
    this.isFeatured = false,
  });

  String get fullImageUrl {
    if (image == null || image!.isEmpty) {
      return ''; 
    }
    
    if (image!.startsWith('http://') || image!.startsWith('https://')) {
      return image!;
    }
    
    final path = image!.startsWith('/') ? image!.substring(1) : image!;
    return 'https://ssp2-assignment-production.up.railway.app/$path';
  }

  static bool _boolFromInt(dynamic value) {
    try {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        if (value.isEmpty) return false;
        final lowerValue = value.toLowerCase().trim();
        return lowerValue == '1' || lowerValue == 'true' || lowerValue == 'yes';
      }
      return false;
    } catch (e) {
      print('Error converting to bool: $value (${value.runtimeType}), error: $e');
      return false;
    }
  }

  static double _priceFromJson(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error parsing price: $value, error: $e');
      return 0.0;
    }
  }

  static double? _discountPriceFromJson(dynamic value) {
    try {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return null;
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    } catch (e) {
      print('Error parsing discount price: $value, error: $e');
      return null;
    }
  }

  static Map<String, dynamic>? _specificationsFromJson(dynamic value) {
    try {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      if (value is String && value.isNotEmpty) {
        final decoded = json.decode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (e) {
      print('Error parsing specifications: $value, error: $e');
      return null;
    }
  }

  static List<Map<String, dynamic>> _reviewsFromJson(dynamic value) {
    try {
      if (value == null) return [];
      if (value is List) {
        return value
            .map((e) {
              if (e is Map<String, dynamic>) return e;
              if (e is Map) return Map<String, dynamic>.from(e);
              return null;
            })
            .whereType<Map<String, dynamic>>()
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing reviews: $value, error: $e');
      return [];
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}