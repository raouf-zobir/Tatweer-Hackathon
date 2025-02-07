class DashboardData {
  final int totalUsers;
  final int activeProjects;
  final int completedProjects;
  final List<ChartData> monthlyStats;

  DashboardData({
    required this.totalUsers,
    required this.activeProjects,
    required this.completedProjects,
    required this.monthlyStats,
  });
}

class ChartData {
  final String month;
  final double value;

  ChartData({required this.month, required this.value});
}
