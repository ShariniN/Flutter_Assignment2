// order_item.dart
import 'package:json_annotation/json_annotation.dart';
import 'product.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  final int id;
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;
  final double price;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
