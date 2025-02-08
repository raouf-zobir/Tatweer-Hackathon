import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final int stock;
  final String category;
  final String description;
  final IconData icon;

  const Product({
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.description,
    required this.icon,
  });

  @override
  String toString() => name;

  // Add a method to create a copy with updated stock
  Product copyWith({int? stock}) {
    return Product(
      name: name,
      price: price,
      stock: stock ?? this.stock,
      category: category,
      description: description,
      icon: icon,
    );
  }
}
