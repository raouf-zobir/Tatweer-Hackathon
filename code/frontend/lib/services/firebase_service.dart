import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeCalendar() async {
    try {
      // Create calendar collection if it doesn't exist
      final calendarRef = _firestore.collection('calendar');
      final doc = await calendarRef.doc('info').get();
      
      if (!doc.exists) {
        await calendarRef.doc('info').set({
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error initializing calendar: $e');
      throw e;
    }
  }
}
