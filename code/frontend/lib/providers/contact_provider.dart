import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact.dart';

class ContactProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Contact> _contacts = [];

  List<Contact> get contacts => List.unmodifiable(_contacts);
  
  List<Contact> getContactsByType(String type) {
    return _contacts.where((contact) => contact.type == type).toList();
  }

  Future<void> loadContacts() async {
    try {
      final snapshot = await _firestore.collection('contacts').get();
      _contacts.clear();
      
      for (var doc in snapshot.docs) {
        _contacts.add(Contact.fromFirestore(doc));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading contacts: $e');
      throw e;
    }
  }

  Future<void> addContact(Contact contact) async {
    try {
      final docRef = await _firestore.collection('contacts').add(contact.toMap());
      final newContact = Contact(
        id: docRef.id,
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        type: contact.type,
      );
      _contacts.add(newContact);
      notifyListeners();
    } catch (e) {
      print('Error adding contact: $e');
      throw e;
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _firestore.collection('contacts').doc(contact.id).update(contact.toMap());
      final index = _contacts.indexWhere((c) => c.id == contact.id);
      if (index != -1) {
        _contacts[index] = contact;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating contact: $e');
      throw e;
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _firestore.collection('contacts').doc(contactId).delete();
      _contacts.removeWhere((contact) => contact.id == contactId);
      notifyListeners();
    } catch (e) {
      print('Error deleting contact: $e');
      throw e;
    }
  }
}
