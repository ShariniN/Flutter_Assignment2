// order.dart
import 'package:json_annotation/json_annotation.dart';
import 'order_item.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'user_id')
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  @JsonKey(name: 'zip_code')
  final String zipCode;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  final String status;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
