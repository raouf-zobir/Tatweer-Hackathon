import 'package:flutter/material.dart';
import '../../constants/style.dart';
import '../components/dashboard_header.dart';

class ScheduleEvent {
  final String title;
  final String description;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Color color;

  ScheduleEvent({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  int _selectedDay = DateTime.now().weekday - 1;
  
  final Map<int, List<ScheduleEvent>> _scheduleData = {
    0: [ // Monday
      ScheduleEvent(
        title: 'Morning Deliveries',
        description: '10 deliveries scheduled',
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 0),
        color: Colors.blue,
      ),
      ScheduleEvent(
        title: 'Team Meeting',
        description: 'Weekly sync',
        startTime: TimeOfDay(hour: 14, minute: 0),
        endTime: TimeOfDay(hour: 15, minute: 30),
        color: Colors.orange,
      ),
    ],
    2: [ // Wednesday
      ScheduleEvent(
        title: 'Warehouse Inspection',
        description: 'Monthly check',
        startTime: TimeOfDay(hour: 9, minute: 0),
        endTime: TimeOfDay(hour: 11, minute: 0),
        color: Colors.green,
      ),
    ],
    4: [ // Friday
      ScheduleEvent(
        title: 'Fleet Maintenance',
        description: 'Regular service',
        startTime: TimeOfDay(hour: 13, minute: 0),
        endTime: TimeOfDay(hour: 17, minute: 0),
        color: Colors.purple,
      ),
    ],
  };

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.access_time),
                    label: Text('Start Time'),
                    onPressed: () {
                      // Implement time picker
                    },
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(Icons.access_time),
                    label: Text('End Time'),
                    onPressed: () {
                      // Implement time picker
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement add event logic
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(title: "Weekly Schedule"),
            SizedBox(height: defaultPadding),
            Container(
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Week Overview",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Add Event"),
                        onPressed: _showAddEventDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: defaultPadding),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        bool hasEvents = _scheduleData.containsKey(index);
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = index),
                          child: Container(
                            width: 80,
                            margin: EdgeInsets.only(right: defaultPadding),
                            decoration: BoxDecoration(
                              color: _selectedDay == index ? primaryColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: hasEvents ? primaryColor : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _weekDays[index].substring(0, 3),
                                  style: TextStyle(
                                    color: _selectedDay == index ? Colors.white : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasEvents)
                                  Container(
                                    margin: EdgeInsets.only(top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _selectedDay == index ? Colors.white : primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: defaultPadding),
                  Container(
                    height: 400,
                    child: _scheduleData.containsKey(_selectedDay)
                        ? ListView.builder(
                            itemCount: _scheduleData[_selectedDay]!.length,
                            itemBuilder: (context, index) {
                              final event = _scheduleData[_selectedDay]![index];
                              return Card(
                                margin: EdgeInsets.only(bottom: defaultPadding),
                                child: ListTile(
                                  leading: Container(
                                    width: 4,
                                    color: event.color,
                                  ),
                                  title: Text(event.title),
                                  subtitle: Text(event.description),
                                  trailing: Text(
                                    '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No events scheduled for ${_weekDays[_selectedDay]}',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
