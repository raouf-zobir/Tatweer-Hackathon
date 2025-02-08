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

  Future<void> loadEvents(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('calendar')
          .doc('events')
          .collection(date.year.toString())
          .doc(date.month.toString())
          .collection('days')
          .get();

      _eventsByDate.clear();

      for (var doc in snapshot.docs) {
        final event = CalendarEvent.fromFirestore(doc);
        final dateKey = DateTime(event.date.year, event.date.month, event.date.day);
        
        if (!_eventsByDate.containsKey(dateKey)) {
          _eventsByDate[dateKey] = [];
        }
        _eventsByDate[dateKey]!.add(event);
      }

      print('Loaded ${snapshot.docs.length} events');
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
      // Simplified path structure
      final docRef = await _firestore
          .collection('calendar')
          .doc('events')
          .collection(event.date.year.toString())
          .doc(event.date.month.toString())
          .collection('days')
          .add(event.toMap());

      print('Added event with ID: ${docRef.id}');
      
      await loadEvents(event.date);
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
