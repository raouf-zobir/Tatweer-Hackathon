import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = provider.dashboardData;
        if (data == null) {
          return const Center(child: Text('No data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsGrid(data),
              const SizedBox(height: 24),
              _buildChart(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(data) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Users', data.totalUsers.toString(), Colors.blue),
        _buildStatCard('Active Projects', data.activeProjects.toString(), Colors.green),
        _buildStatCard('Completed Projects', data.completedProjects.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(data) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.monthlyStats.length) {
                        return Text(data.monthlyStats[value.toInt()].month);
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: data.monthlyStats.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
