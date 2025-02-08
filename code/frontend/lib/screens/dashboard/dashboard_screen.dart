import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../models/dashboard_stats.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/responsive.dart';
import '../../components/page_title.dart';

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
      context.read<DashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        
        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(
                title: "Dashboard Overview",
                subtitle: "Monitor your business performance",
                icon: Icons.dashboard_outlined,
                actions: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                        vertical: defaultPadding / 2,
                      ),
                    ),
                    onPressed: () => provider.loadStats(),
                    icon: Icon(Icons.refresh),
                    label: Text("Refresh"),
                  ),
                ],
              ),
              SizedBox(height: defaultPadding),
              _buildStatsGrid(stats),
              SizedBox(height: defaultPadding),
              _buildChart(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
      crossAxisSpacing: defaultPadding,
      mainAxisSpacing: defaultPadding,
      children: [
        _buildStatCard(
          "In Transit",
          "${stats.inTransit}",
          Icons.local_shipping,
          Colors.blue,
        ),
        _buildStatCard(
          "Delivered",
          "${stats.delivered}",
          Icons.done_all,
          Colors.green,
        ),
        _buildStatCard(
          "Returned",
          "${stats.returned}",
          Icons.assignment_return,
          Colors.red,
        ),
        _buildStatCard(
          "Revenue",
          "\$${stats.revenue.toStringAsFixed(2)}",
          Icons.attach_money,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(defaultPadding / 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
            ],
          ),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(DashboardStats stats) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Statistics",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: defaultPadding),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < stats.monthlyDeliveries.length) {
                          return Text(stats.monthlyDeliveries[index].month);
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: stats.monthlyDeliveries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.deliveries.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: primaryColor,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: stats.monthlyDeliveries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.returns.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
