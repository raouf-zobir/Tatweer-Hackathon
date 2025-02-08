import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String type;
  final String status;
  final Color color;
  final String createdBy;

  CalendarEvent({
    this.id = '',
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.status = 'pending',
    this.color = Colors.blue,
    required this.createdBy,
  });

  factory CalendarEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CalendarEvent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: _timeFromString(data['startTime'] ?? '09:00'),
      endTime: _timeFromString(data['endTime'] ?? '10:00'),
      type: data['type'] ?? '',
      status: data['status'] ?? 'pending',
      color: Color(data['color'] ?? Colors.blue.value),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'startTime': '${startTime.hour}:${startTime.minute}',
      'endTime': '${endTime.hour}:${endTime.minute}',
      'type': type,
      'status': status,
      'color': color.value,
      'createdBy': createdBy,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String getMonthPath(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  static CollectionReference getEventsCollection(DateTime date) {
    return FirebaseFirestore.instance
        .collection('calendar')
        .doc(getMonthPath(date))
        .collection('events');
  }
}
