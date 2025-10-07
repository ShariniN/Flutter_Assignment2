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
  final String? imagePath;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    this.user,
    this.comment,
    required this.rating,
    this.createdAt,
    this.imagePath,
  });

  static double _ratingFromJson(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return 0.0;
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      print('Error parsing rating: $value, error: $e');
      return 0.0;
    }
  }

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}