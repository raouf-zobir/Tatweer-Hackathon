import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/style.dart';
import '../../models/dashboard_stats.dart';
import '../components/dashboard_header.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final DeliveryStats stats = DeliveryStats(
    inTransit: 156,
    delivered: 892,
    returned: 54,
    pending: 78,
    revenue: 127850.00,
    monthlyDeliveries: [
      ChartData(month: 'Jan', deliveries: 450, returns: 45),
      ChartData(month: 'Feb', deliveries: 520, returns: 38),
      ChartData(month: 'Mar', deliveries: 480, returns: 42),
      ChartData(month: 'Apr', deliveries: 630, returns: 35),
      ChartData(month: 'May', deliveries: 580, returns: 48),
      ChartData(month: 'Jun', deliveries: 750, returns: 52),
    ],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            DashboardHeader(title: "Logistics Dashboard"),
            const SizedBox(height: defaultPadding),
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overview",
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Last 24 hours performance",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildOverviewStat(
                            title: "Success Rate",
                            value: "95%",
                            color: Colors.green,
                            icon: Icons.trending_up,
                          ),
                          SizedBox(width: defaultPadding),
                          _buildOverviewStat(
                            title: "On Time",
                            value: "98%",
                            color: primaryColor,
                            icon: Icons.timer,
                          ),
                          SizedBox(width: defaultPadding),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: defaultPadding,
                                vertical: defaultPadding / 2,
                              ),
                            ),
                            onPressed: () {
                              _animationController.reset();
                              _animationController.forward();
                              // Add your refresh logic here
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Refresh"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      _buildTimePeriodButton(
                        "Today",
                        isSelected: true,
                      ),
                      SizedBox(width: defaultPadding / 2),
                      _buildTimePeriodButton("Week"),
                      SizedBox(width: defaultPadding / 2),
                      _buildTimePeriodButton("Month"),
                      Spacer(),
                      _buildExportButton(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.2, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: _animationController,
                child: _buildStatsGrid(),
              ),
            ),
            const SizedBox(height: defaultPadding),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.2, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: _animationController,
                child: _buildDeliveryChart(),
              ),
            ),
            const SizedBox(height: defaultPadding),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: _animationController,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildRecentDeliveries(),
                    ),
                    if (!Responsive.isMobile(context))
                      const SizedBox(width: defaultPadding),
                    if (!Responsive.isMobile(context))
                      Expanded(
                        child: _buildAlerts(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: defaultPadding / 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodButton(String text, {bool isSelected = false}) {
    return OutlinedButton(
      onPressed: () {
        // Implement time period selection
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? primaryColor : Colors.transparent,
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.white24,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.download, color: Colors.white70),
          SizedBox(width: 4),
          Text(
            'Export',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.red),
              SizedBox(width: 8),
              Text('Export as PDF'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.green),
              SizedBox(width: 8),
              Text('Export as Excel'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        // Implement export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exporting as $value...')),
        );
      },
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
      crossAxisSpacing: defaultPadding,
      mainAxisSpacing: defaultPadding,
      children: [
        _buildStatCard(
          "In Transit",
          stats.inTransit.toString(),
          Icons.local_shipping,
          Colors.blue,
        ),
        _buildStatCard(
          "Delivered",
          stats.delivered.toString(),
          Icons.done_all,
          Colors.green,
        ),
        _buildStatCard(
          "Returned",
          stats.returned.toString(),
          Icons.assignment_return,
          Colors.red,
        ),
        _buildStatCard(
          "Pending",
          stats.pending.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(defaultPadding * 0.75),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              Icon(Icons.more_vert, color: Colors.white54),
            ],
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryChart() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
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
          const SizedBox(height: defaultPadding),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: stats.monthlyDeliveries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.deliveries);
                    }).toList(),
                    isCurved: true,
                    color: primaryColor,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: stats.monthlyDeliveries.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.returns);
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

  Widget _buildRecentDeliveries() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Deliveries",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Icon(Icons.local_shipping, color: Colors.white),
                  ),
                  title: Text("Delivery #${1000 + index}"),
                  subtitle: Text("Customer Name ${index + 1}"),
                  trailing: _getStatusChip(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Alerts",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding),
          _buildAlert("Delayed Delivery", "Package #1234 is delayed", Colors.orange),
          _buildAlert("Failed Delivery", "Package #5678 delivery failed", Colors.red),
          _buildAlert("Success", "Package #9012 delivered", Colors.green),
        ],
      ),
    );
  }

  Widget _buildAlert(String title, String message, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      child: ListTile(
        leading: Icon(Icons.notification_important, color: color),
        title: Text(title),
        subtitle: Text(message),
      ),
    );
  }

  Widget _getStatusChip(int index) {
    final statuses = [
      {'label': 'Delivered', 'color': Colors.green},
      {'label': 'In Transit', 'color': Colors.blue},
      {'label': 'Pending', 'color': Colors.orange},
      {'label': 'Delivered', 'color': Colors.green},
      {'label': 'In Transit', 'color': Colors.blue},
    ];

    return Chip(
      label: Text(
        statuses[index]['label'] as String,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: statuses[index]['color'] as Color,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
