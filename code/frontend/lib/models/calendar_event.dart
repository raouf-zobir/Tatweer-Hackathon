import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type;
  final String status;
  final Color color;
  final String createdBy;

  CalendarEvent({
    this.id = '',
    required this.title,
    required this.description,
    required this.date,
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
      'type': type,
      'status': status,
      'color': color.value,
      'createdBy': createdBy,
      'timestamp': FieldValue.serverTimestamp(),
    };
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
