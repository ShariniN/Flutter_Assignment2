// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistItem _$WishlistItemFromJson(Map<String, dynamic> json) => WishlistItem(
      id: json['_id'] as String,
      userId: (json['user_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      product: json['product'] == null
          ? null
          : Product.fromJson(json['product'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WishlistItemToJson(WishlistItem instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'user_id': instance.userId,
      'product_id': instance.productId,
      'product': instance.product,
    };
