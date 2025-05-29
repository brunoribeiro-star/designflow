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

  /// Carrega tipos de serviço do Firestore
  Future<void> fetchServiceTypes() async {
    if (_userId == null) return;
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .orderBy('createdAt')
        .get();

    _serviceTypes.clear();
    _serviceTypes.addAll(snapshot.docs.map((doc) {
      final data = doc.data();
      return ServiceType(
        id: doc.id,
        name: data['name'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }));
    notifyListeners();
  }

  /// Adiciona tipo de serviço no Firestore
  Future<void> addServiceType(ServiceType type) async {
    if (_userId == null) return;
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('service_types')
        .add(type.toFirestore());
    // Agora salva id do firestore (String)
    _serviceTypes.add(type.copyWith(id: doc.id));
    notifyListeners();
  }

  /// Atualiza tipo de serviço
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

  /// Remove tipo de serviço
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
    try {
      return _serviceTypes.firstWhere((t) => t.id == id);
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