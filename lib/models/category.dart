import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'is_active', fromJson: _boolFromJson)
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  static bool _boolFromJson(dynamic value) {
    print('🔧 Converting to bool: $value (type: ${value.runtimeType})');
    try {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value == '1' || value.toLowerCase() == 'true';
      }
      return true;
    } catch (e) {
      print('❌ Error converting $value to bool: $e');
      return true;
    }
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    print('🎯 Parsing Category from JSON: $json');
    return _$CategoryFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}