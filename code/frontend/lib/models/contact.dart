import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String type; // 'Supplier', 'Client', or 'Distributor'

  Contact({
    this.id = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
  });

  factory Contact.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Contact(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      type: data['type'] ?? 'Client',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
