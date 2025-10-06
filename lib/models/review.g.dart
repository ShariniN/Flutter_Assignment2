// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      comment: json['comment'] as String?,
      rating: Review._ratingFromJson(json['rating']),
      createdAt: json['created_at'] as String?,
      imagePath: json['image_path'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'user_id': instance.userId,
      'user': instance.user,
      'comment': instance.comment,
      'rating': instance.rating,
      'created_at': instance.createdAt,
      'image_path': instance.imagePath,
    };
