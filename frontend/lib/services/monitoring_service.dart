import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/disruption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonitoringService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _apiUrl = 'http://localhost:8000/api'; // FastAPI endpoint

  Stream<List<Disruption>> getDisruptions() {
    return _firestore
        .collection('disruptions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Disruption.fromJson(doc.data()))
          .toList();
    });
  }

  Future<void> acknowledgeDisruption(String disruptionId) async {
    await http.post(
      Uri.parse('$_apiUrl/acknowledge-disruption'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'disruption_id': disruptionId}),
    );
  }

  Future<void> applyAiSolution(String disruptionId, String solution) async {
    await http.post(
      Uri.parse('$_apiUrl/apply-solution'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'disruption_id': disruptionId,
        'solution': solution,
      }),
    );
  }
}
