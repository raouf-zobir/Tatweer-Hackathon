import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/style.dart';
import '../../components/page_title.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  void initState() {
    super.initState();
    // Load current month's events when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().loadEvents(DateTime.now());
    });
  }

  void _addTestEvent() async {
    try {
      final event = CalendarEvent(
        title: 'Test Event',
        description: 'Testing Firebase Integration',
        date: DateTime.now(),
        type: 'test',
        createdBy: 'system',
      );
      
      await context.read<CalendarProvider>().addEvent(event);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            PageTitle(
              title: "Calendar",
              subtitle: "Manage your events",
              icon: Icons.calendar_today,
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding / 2,
                    ),
                  ),
                  onPressed: _addTestEvent,
                  icon: Icon(Icons.add),
                  label: Text("Test Add Event"),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            Consumer<CalendarProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (provider.eventsByDate.isEmpty) {
                  return Center(child: Text('No events found'));
                }

                return Column(
                  children: provider.eventsByDate.entries.map((entry) {
                    return Card(
                      margin: EdgeInsets.only(bottom: defaultPadding),
                      child: ListTile(
                        title: Text(
                          '${entry.key.day}/${entry.key.month}/${entry.key.year}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entry.value.map((event) => 
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Text('${event.title} - ${event.description}'),
                            ),
                          ).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
