import 'package:flutter/material.dart';
import '../widgets/disruption_card.dart';
import '../widgets/monitoring_chart.dart';
import '../services/monitoring_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MonitoringService _monitoringService = MonitoringService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supply Chain Monitor')),
      body: Row(
        children: [
          // Navigation Sidebar
          NavigationRail(
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.warning),
                label: Text('Disruptions'),
              ),
            ],
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Handle navigation
            },
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonitoringChart(),
                  SizedBox(height: 20),
                  Text('Active Disruptions',
                      style: Theme.of(context).textTheme.headline6),
                  Expanded(
                    child: StreamBuilder(
                      stream: _monitoringService.getDisruptions(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return DisruptionCard(
                                disruption: snapshot.data[index],
                              );
                            },
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
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
