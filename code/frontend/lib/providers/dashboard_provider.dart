import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_stats.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DashboardStats? _stats;
  bool _isLoading = false;
  dynamic dashboardData;

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('dashboard_stats').doc('current').get();
      
      if (snapshot.exists) {
        _stats = DashboardStats.fromFirestore(snapshot);
        dashboardData = snapshot.data();
      } else {
        // Initialize with default values if no data exists
        _stats = DashboardStats(
          inTransit: 0,
          delivered: 0,
          returned: 0,
          pending: 0,
          revenue: 0,
          monthlyDeliveries: [
            ChartData(month: 'Jan', deliveries: 0, returns: 0),
            ChartData(month: 'Feb', deliveries: 0, returns: 0),
            ChartData(month: 'Mar', deliveries: 0, returns: 0),
            ChartData(month: 'Apr', deliveries: 0, returns: 0),
            ChartData(month: 'May', deliveries: 0, returns: 0),
            ChartData(month: 'Jun', deliveries: 0, returns: 0),
          ],
        );
        // Save default values to Firebase
        await _firestore.collection('dashboard_stats').doc('current').set(_stats!.toMap());
        dashboardData = _stats!.toMap();
      }
    } catch (e) {
      print('Error loading dashboard stats: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadStats(); // Reuse existing loadStats method
      // Additional dashboard data loading can be added here
    } catch (e) {
      print('Error loading dashboard data: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
