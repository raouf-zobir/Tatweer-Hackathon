import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String toContactId;
  final String toName;
  final String toEmail;
  final String content;
  final DateTime timestamp;
  final String status;

  Message({
    this.id = '',
    required this.toContactId,
    required this.toName,
    required this.toEmail,
    required this.content,
    DateTime? timestamp,
    this.status = 'sent',
  }) : this.timestamp = timestamp ?? DateTime.now();

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      toContactId: data['toContactId'] ?? '',
      toName: data['toName'] ?? '',
      toEmail: data['toEmail'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'sent',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toContactId': toContactId,
      'toName': toName,
      'toEmail': toEmail,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}
