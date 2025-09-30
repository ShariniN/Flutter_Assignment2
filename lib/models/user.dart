import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'is_admin')
  final bool isAdmin;

  // Add this 👇
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle token if it's outside "user" object
    if (json.containsKey('user')) {
      return User(
        id: json['user']['id'],
        name: json['user']['name'],
        email: json['user']['email'],
        isAdmin: json['user']['is_admin'] ?? false,
        token: json['token'],
      );
    }
    return _$UserFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

