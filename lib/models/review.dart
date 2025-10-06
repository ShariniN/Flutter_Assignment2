import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;

  @JsonKey(name: 'product_id')
  final int productId;

  @JsonKey(name: 'user_id')
  final int userId;

  final User? user;

  final String? comment;

  @JsonKey(fromJson: _ratingFromJson)
  final double rating;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'image_path')
  final String? imagePath;  // Add this field

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    this.user,
    this.comment,
    required this.rating,
    this.createdAt,
    this.imagePath,  // Add this parameter
  });

  static double _ratingFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return (value as num).toDouble();
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}