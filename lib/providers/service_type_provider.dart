import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_type.dart';

class ServiceTypeProvider with ChangeNotifier {
  final List<ServiceType> _serviceTypes = [];
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<ServiceType> get serviceTypes => List.unmodifiable(_serviceTypes);

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadServiceTypes() async {
    if (_userId == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .orderBy('createdAt', descending: true)
        .get();

    _serviceTypes.clear();
    _serviceTypes.addAll(snapshot.docs.map((doc) => ServiceType.fromFirestore(doc)));
    notifyListeners();
  }

  Future<void> addServiceType(ServiceType type) async {
    if (_userId == null) return;
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .add(type.toFirestore());
    _serviceTypes.insert(0, type.copyWith(id: doc.id));
    notifyListeners();
  }

  Future<void> updateServiceType(ServiceType type) async {
    if (_userId == null || type.id == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .doc(type.id)
        .update(type.toFirestore());
    final index = _serviceTypes.indexWhere((t) => t.id == type.id);
    if (index != -1) {
      _serviceTypes[index] = type;
      notifyListeners();
    }
  }

  Future<void> removeServiceType(ServiceType type) async {
    if (_userId == null || type.id == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .doc(type.id)
        .delete();
    _serviceTypes.removeWhere((t) => t.id == type.id);
    notifyListeners();
  }

  ServiceType? findById(String? id) {
    if (id == null) return null;
    try {
      return _serviceTypes.firstWhere((st) => st.id == id);
    } catch (_) {
      return null;
    }
  }

  ServiceType? findByName(String name) {
    try {
      return _serviceTypes.firstWhere(
            (t) => t.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _serviceTypes.clear();
    notifyListeners();
  }
}

extension on ServiceType {
  ServiceType copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return ServiceType(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}