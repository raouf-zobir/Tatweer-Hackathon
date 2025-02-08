import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/style.dart';
import '../../components/page_title.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  int _selectedDay = DateTime.now().weekday - 1;
  
  final Map<int, List<ScheduleEvent>> _scheduleData = {};

  Future<void> _saveEventToFirebase(ScheduleEvent event) async {
    try {
      print('Attempting to save event to Firebase...');
      
      // Create a document in the events collection for the specific day
      final docRef = await _firestore
          .collection('weekly_schedule')
          .doc(_selectedDay.toString())
          .collection('events')
          .add({
        'title': event.title,
        'description': event.description,
        'startTime': '${event.startTime.hour}:${event.startTime.minute}',
        'endTime': '${event.endTime.hour}:${event.endTime.minute}',
        'color': event.color.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Event saved with ID: ${docRef.id}');

      // Update local state
      if (!_scheduleData.containsKey(_selectedDay)) {
        _scheduleData[_selectedDay] = [];
      }
      _scheduleData[_selectedDay]!.add(event);
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event saved successfully')),
      );
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirebase();
  }

  Future<void> _loadEventsFromFirebase() async {
    try {
      print('Loading events from Firebase...');
      _scheduleData.clear();

      // Load events for all days
      for (int day = 0; day < 7; day++) {
        final snapshot = await _firestore
            .collection('weekly_schedule')
            .doc(day.toString())
            .collection('events')
            .orderBy('createdAt')
            .get();

        if (snapshot.docs.isNotEmpty) {
          _scheduleData[day] = snapshot.docs.map((doc) {
            final data = doc.data();
            final startTimeParts = data['startTime'].split(':');
            final endTimeParts = data['endTime'].split(':');

            return ScheduleEvent(
              title: data['title'],
              description: data['description'],
              startTime: TimeOfDay(
                hour: int.parse(startTimeParts[0]),
                minute: int.parse(startTimeParts[1]),
              ),
              endTime: TimeOfDay(
                hour: int.parse(endTimeParts[0]),
                minute: int.parse(endTimeParts[1]),
              ),
              color: Color(data['color']),
            );
          }).toList();
        }
      }

      print('Events loaded successfully');
      setState(() {});
    } catch (e) {
      print('Error loading events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading events: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay startTime = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = TimeOfDay(hour: 10, minute: 0);
    Color selectedColor = Colors.blue;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    icon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.access_time),
                        label: Text(startTime.format(context)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null) {
                            setStateDialog(() => startTime = time);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.access_time),
                        label: Text(endTime.format(context)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null) {
                            setStateDialog(() => endTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Text('Color: '),
                    SizedBox(width: defaultPadding),
                    ...colors.map((color) => GestureDetector(
                      onTap: () => setStateDialog(() => selectedColor = color),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color 
                              ? Colors.white 
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an event title')),
                  );
                  return;
                }

                final newEvent = ScheduleEvent(
                  title: titleController.text,
                  description: descriptionController.text,
                  startTime: startTime,
                  endTime: endTime,
                  color: selectedColor,
                );

                await _saveEventToFirebase(newEvent);
                await _loadEventsFromFirebase();  // Reload events
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventOptions(ScheduleEvent event, int eventIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: primaryColor),
              title: Text('Edit Event'),
              onTap: () {
                Navigator.pop(context);
                _showEditEventDialog(event, eventIndex);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Event'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(eventIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditEventDialog(ScheduleEvent event, int eventIndex) async {
    final titleController = TextEditingController(text: event.title);
    final descriptionController = TextEditingController(text: event.description);
    TimeOfDay startTime = event.startTime;
    TimeOfDay endTime = event.endTime;
    Color selectedColor = event.color;

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    icon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: defaultPadding),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    icon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.access_time),
                        label: Text(startTime.format(context)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null) {
                            setStateDialog(() => startTime = time);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: Icon(Icons.access_time),
                        label: Text(endTime.format(context)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null) {
                            setStateDialog(() => endTime = time);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: defaultPadding),
                Row(
                  children: [
                    Text('Color: '),
                    SizedBox(width: defaultPadding),
                    ...colors.map((color) => GestureDetector(
                      onTap: () => setStateDialog(() => selectedColor = color),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color 
                              ? Colors.white 
                              : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an event title')),
                  );
                  return;
                }

                setState(() {
                  _scheduleData[_selectedDay]![eventIndex] = ScheduleEvent(
                    title: titleController.text,
                    description: descriptionController.text,
                    startTime: startTime,
                    endTime: endTime,
                    color: selectedColor,
                  );
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event updated successfully')),
                );
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEventFromFirebase(int dayIndex, int eventIndex) async {
    try {
      print('Deleting event from Firebase...');
      
      final snapshot = await _firestore
          .collection('weekly_schedule')
          .doc(dayIndex.toString())
          .collection('events')
          .get();

      if (snapshot.docs.length > eventIndex) {
        await snapshot.docs[eventIndex].reference.delete();
        
        setState(() {
          _scheduleData[dayIndex]!.removeAt(eventIndex);
          if (_scheduleData[dayIndex]!.isEmpty) {
            _scheduleData.remove(dayIndex);
          }
        });

        print('Event deleted successfully');
      }
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }

  void _showDeleteConfirmation(int eventIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await _deleteEventFromFirebase(_selectedDay, eventIndex);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Event deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting event: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(ScheduleEvent event, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: defaultPadding),
      child: ListTile(
        leading: Container(
          width: 4,
          color: event.color,
        ),
        title: Text(event.title),
        subtitle: Text(event.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${event.startTime.format(context)} - ${event.endTime.format(context)}',
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showEventOptions(event, index),
            ),
          ],
        ),
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
            PageTitle(
              title: "Weekly Schedule",
              subtitle: "Manage and track your delivery schedule",
              icon: Icons.calendar_month,
            ),
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
                              return _buildEventCard(event, index);
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
