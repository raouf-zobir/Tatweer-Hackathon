import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> loadOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();
      _orders.clear();
      
      for (var doc in snapshot.docs) {
        _orders.add(Order.fromFirestore(doc));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading orders: $e');
      throw e;
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      final newOrder = Order(
        id: docRef.id,
        clientName: order.clientName,
        city: order.city,
        deliveryDate: order.deliveryDate,
        items: order.items,
        status: order.status,
      );
      _orders.add(newOrder);
      notifyListeners();
    } catch (e) {
      print('Error adding order: $e');
      throw e;
    }
  }

  Future<void> updateOrderStatus(Order order, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(order.id).update({
        'status': newStatus,
      });

      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index].status = newStatus;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order status: $e');
      throw e;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).delete();
      _orders.removeWhere((order) => order.id == orderId);
      notifyListeners();
    } catch (e) {
      print('Error deleting order: $e');
      throw e;
    }
  }
}
