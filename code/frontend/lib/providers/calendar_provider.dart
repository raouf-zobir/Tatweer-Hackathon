import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event.dart';

class CalendarProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<DateTime, List<CalendarEvent>> _eventsByDate = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Map<DateTime, List<CalendarEvent>> get eventsByDate => _eventsByDate;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadEvents(DateTime month) async {
    _isLoading = true;
    notifyListeners();

    try {
      print('Loading events for month: ${month.month}/${month.year}');
      final monthPath = CalendarEvent.getMonthPath(month);
      print('Month path: $monthPath');

      final snapshot = await _firestore
          .collection('calendar')
          .doc(monthPath)
          .collection('events')
          .orderBy('timestamp', descending: true)
          .get();

      print('Found ${snapshot.docs.length} events');

      _eventsByDate.clear();
      
      for (var doc in snapshot.docs) {
        final event = CalendarEvent.fromFirestore(doc);
        final dateKey = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );

        if (!_eventsByDate.containsKey(dateKey)) {
          _eventsByDate[dateKey] = [];
        }
        _eventsByDate[dateKey]!.add(event);
      }

      print('Events loaded successfully');
    } catch (e) {
      print('Error loading events: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(CalendarEvent event) async {
    try {
      print('Adding event to Firebase: ${event.title}');
      final monthPath = CalendarEvent.getMonthPath(event.date);
      print('Month path: $monthPath');

      // Create the month document if it doesn't exist
      await _firestore.collection('calendar').doc(monthPath).set({
        'month': monthPath,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Add the event to the events subcollection
      final docRef = await _firestore
          .collection('calendar')
          .doc(monthPath)
          .collection('events')
          .add(event.toMap());

      print('Event added with ID: ${docRef.id}');

      // Add to local state
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );

      if (!_eventsByDate.containsKey(dateKey)) {
        _eventsByDate[dateKey] = [];
      }

      _eventsByDate[dateKey]!.add(
        CalendarEvent(
          id: docRef.id,
          title: event.title,
          description: event.description,
          date: event.date,
          startTime: event.startTime,
          endTime: event.endTime,
          type: event.type,
          status: event.status,
          color: event.color,
          createdBy: event.createdBy,
        ),
      );

      notifyListeners();
      print('Event added successfully');
    } catch (e) {
      print('Error adding event: $e');
      throw e;
    }
  }

  Future<void> updateEvent(CalendarEvent event) async {
    try {
      final eventsCollection = CalendarEvent.getEventsCollection(event.date);
      await eventsCollection.doc(event.id).update(event.toMap());

      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
      final index = _eventsByDate[dateKey]?.indexWhere((e) => e.id == event.id) ?? -1;
      if (index != -1) {
        _eventsByDate[dateKey]![index] = event;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating event: $e');
      throw e;
    }
  }

  Future<void> deleteEvent(CalendarEvent event) async {
    try {
      final eventsCollection = CalendarEvent.getEventsCollection(event.date);
      await eventsCollection.doc(event.id).delete();

      final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
      _eventsByDate[dateKey]?.removeWhere((e) => e.id == event.id);
      if (_eventsByDate[dateKey]?.isEmpty ?? false) {
        _eventsByDate.remove(dateKey);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error deleting event: $e');
      throw e;
    }
  }
}
