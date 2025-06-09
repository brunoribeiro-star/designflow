import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/client.dart';

class ClientProvider with ChangeNotifier {
  final List<Client> _clients = [];

  List<Client> get clients => List.unmodifiable(_clients);

  Future<void> loadClients() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('clients')
        .get();

    _clients.clear();
    for (var doc in snapshot.docs) {
      _clients.add(Client.fromFirestore(doc));
    }
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('clients')
        .add(client.toFirestore());

    client.id = ref.id;
    _clients.add(client);
    notifyListeners();
  }

  Future<void> removeClient(Client client) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || client.id == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('clients')
        .doc(client.id)
        .delete();

    _clients.removeWhere((c) => c.id == client.id);
    notifyListeners();
  }

  Client? findByName(String name) {
    try {
      return _clients.firstWhere(
            (client) => client.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Client? findById(String? id) {
    if (id == null) return null;
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Client> searchClients(String query) {
    return _clients
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}