// cart.dart
import 'package:json_annotation/json_annotation.dart';
import 'cart_item.dart';

part 'cart.g.dart';

@JsonSerializable()
class Cart {
  final int id;
  @JsonKey(name: 'user_id')
  final int? userId;
  @JsonKey(name: 'session_id')
  final String? sessionId;
  final List<CartItem>? items;

  Cart({
    required this.id,
    this.userId,
    this.sessionId,
    this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
  Map<String, dynamic> toJson() => _$CartToJson(this);
}
