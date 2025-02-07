import '../models/dashboard_model.dart';

class DashboardService {
  Future<DashboardData> getDashboardData() async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    return DashboardData(
      totalUsers: 1234,
      activeProjects: 42,
      completedProjects: 128,
      monthlyStats: [
        ChartData(month: 'Jan', value: 30),
        ChartData(month: 'Feb', value: 45),
        ChartData(month: 'Mar', value: 35),
        ChartData(month: 'Apr', value: 60),
        ChartData(month: 'May', value: 48),
        ChartData(month: 'Jun', value: 52),
      ],
    );
  }
}
