import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  // Add method to check if product exists
  Future<bool> productExists(String productName) async {
    final querySnapshot = await _firestore
        .collection('products')
        .where('name', isEqualTo: productName)
        .get();
    
    return querySnapshot.docs.isNotEmpty;
  }

  // Initialize and load products from Firebase
  Future<void> loadProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      _products.clear();
      for (var doc in snapshot.docs) {
        _products.add(Product(
          name: doc['name'],
          price: doc['price'].toDouble(),
          stock: doc['stock'],
          category: doc['category'],
          description: doc['description'],
          icon: IconData(doc['iconCode'], fontFamily: 'MaterialIcons'),
        ));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      // Check if product already exists
      if (await productExists(product.name)) {
        throw 'Product with this name already exists';
      }

      // Add to Firebase
      await _firestore.collection('products').add({
        'name': product.name,
        'price': product.price,
        'stock': product.stock,
        'category': product.category,
        'description': product.description,
        'iconCode': product.icon.codePoint,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add to local list
      _products.add(product);
      notifyListeners();
    } catch (e) {
      print('Error adding product: $e');
      throw e; // Rethrow to handle in UI
    }
  }

  Future<void> updateStock(Product product, int newStock) async {
    try {
      // Find document with matching name
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: product.name)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'stock': newStock,
        });
      }

      final index = _products.indexOf(product);
      if (index != -1) {
        _products[index] = product.copyWith(stock: newStock);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating stock: $e');
      throw e;
    }
  }

  bool hasEnoughStock(Product product, int quantity) {
    return product.stock >= quantity;
  }

  Future<void> updateProduct(String productName, Product updatedProduct) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          'name': updatedProduct.name,
          'price': updatedProduct.price,
          'stock': updatedProduct.stock,
          'category': updatedProduct.category,
          'description': updatedProduct.description,
          'iconCode': updatedProduct.icon.codePoint,
        });

        final index = _products.indexWhere((p) => p.name == productName);
        if (index != -1) {
          _products[index] = updatedProduct;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error updating product: $e');
      throw e;
    }
  }

  Future<void> deleteProduct(String productName) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('name', isEqualTo: productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        _products.removeWhere((p) => p.name == productName);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting product: $e');
      throw e;
    }
  }
}
