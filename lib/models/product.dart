import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String brand;
  final Color? color;
  final String category;
  final double rating;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.brand,
    this.color,
    required this.category,
    this.rating = 4.0,
    required this.imageUrl, 
  });

  IconData get categoryIcon {
    switch (category) {
      case 'phone':
        return Icons.smartphone;
      case 'laptop':
        return Icons.laptop;
      case 'audio':
        return Icons.headphones;
      case 'wearables':
        return Icons.watch;
      case 'accessories':
        return Icons.cable;
      default:
        return Icons.category;
    }
  }

  bool get hasValidImage => imageUrl.isNotEmpty;
}