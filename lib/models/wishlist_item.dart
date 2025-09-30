import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'wishlist_item.g.dart';

@JsonSerializable()
class WishlistItem {
  @JsonKey(name: '_id')
  final String id; // MongoDB ID is a string
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'product_id')
  final int productId;
  final Product? product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemToJson(this);
}
