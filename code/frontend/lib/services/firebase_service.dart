import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeWeeklySchedule() async {
    try {
      // Create weekly_schedule collection if it doesn't exist
      final weeklyRef = _firestore.collection('weekly_schedule');
      final doc = await weeklyRef.doc('info').get();
      
      if (!doc.exists) {
        await weeklyRef.doc('info').set({
          'created_at': FieldValue.serverTimestamp(),
          'last_updated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error initializing weekly schedule: $e');
      throw e;
    }
  }
}
