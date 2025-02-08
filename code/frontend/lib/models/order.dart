import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id; // Add this field for Firebase document ID
  final String clientName;
  final String city;
  final DateTime deliveryDate;
  final List<OrderItem> items;
  String status;

  Order({
    this.id = '',  // Default empty for new orders
    required this.clientName,
    required this.city,
    required this.deliveryDate,
    required this.items,
    required this.status,
  });

  // Add factory method to create from Firebase
  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      clientName: data['clientName'] ?? '',
      city: data['city'] ?? '',
      deliveryDate: (data['deliveryDate'] as Timestamp).toDate(),
      items: (data['items'] as List).map((item) => OrderItem.fromMap(item)).toList(),
      status: data['status'] ?? 'Pending',
    );
  }

  // Add method to convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'clientName': clientName,
      'city': city,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
    };
  }
}

class OrderItem {
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}
