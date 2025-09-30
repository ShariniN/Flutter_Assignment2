import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'product.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'product_id')
  final int productId;
  final String? content;
  final int? rating;
  final User? user;
  final Product? product;

  Review({
    required this.id,
    required this.userId,
    required this.productId,
    this.content,
    this.rating,
    this.user,
    this.product,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
