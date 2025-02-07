import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();
  DashboardData? _dashboardData;
  bool _isLoading = false;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
