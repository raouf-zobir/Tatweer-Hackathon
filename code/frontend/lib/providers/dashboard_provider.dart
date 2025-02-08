import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

enum TimeRange { day, week, month }

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service = DashboardService();
  DashboardData? _dashboardData;
  bool _isLoading = false;
  TimeRange _selectedTimeRange = TimeRange.day;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  TimeRange get selectedTimeRange => _selectedTimeRange;

  // New: time frame state and data
  String _currentTimeFrame = 'day';
  String get currentTimeFrame => _currentTimeFrame;

  dynamic _data;
  dynamic get data => _data;

  DashboardProvider() {
    // Initialize data for default time frame
    fetchDataForTimeFrame();
  }

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

  bool _isTransitioning = false;
  bool get isTransitioning => _isTransitioning;

  Future<void> setTimeRange(TimeRange range) async {
    if (_selectedTimeRange == range) return;
    
    // Start transition
    _isTransitioning = true;
    notifyListeners();

    // Wait for fade out
    await Future.delayed(const Duration(milliseconds: 300));
    
    _selectedTimeRange = range;
    await refreshDashboardData();
    
    // End transition
    _isTransitioning = false;
    notifyListeners();
  }

  Future<void> refreshDashboardData() async {
    // Update this method to fetch data based on _selectedTimeRange
    // Example:
    switch (_selectedTimeRange) {
      case TimeRange.day:
        // Fetch daily data
        break;
      case TimeRange.week:
        // Fetch weekly data
        break;
      case TimeRange.month:
        // Fetch monthly data
        break;
    }
  }

  // New: method to update time frame and refresh data
  void updateTimeFrame(String newTimeFrame) {
    if (_currentTimeFrame != newTimeFrame) {
      _currentTimeFrame = newTimeFrame;
      fetchDataForTimeFrame();
      notifyListeners();
    }
  }

  // New: dummy method to simulate fetching data based on current time frame
  void fetchDataForTimeFrame() {
    // Replace this logic with your actual data fetching implementation.
    if (_currentTimeFrame == 'day') {
      _data = 'Day data';
    } else if (_currentTimeFrame == 'week') {
      _data = 'Week data';
    } else if (_currentTimeFrame == 'month') {
      _data = 'Month data';
    }
  }
}
