// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: Product._priceFromJson(json['price']),
      discountPrice: Product._discountPriceFromJson(json['discount_price']),
      stockQuantity: (json['stock_quantity'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      sku: json['sku'] as String?,
      image: json['image'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      isActive: json['is_active'] == null
          ? true
          : Product._boolFromInt(json['is_active']),
      isFeatured: json['is_featured'] == null
          ? false
          : Product._boolFromInt(json['is_featured']),
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'discount_price': instance.discountPrice,
      'stock_quantity': instance.stockQuantity,
      'category_id': instance.categoryId,
      'category': instance.category,
      'sku': instance.sku,
      'image': instance.image,
      'specifications': instance.specifications,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
    };
