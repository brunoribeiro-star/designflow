import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceType {
  String? id; // Firestore document ID
  String name;
  DateTime createdAt;

  ServiceType({
    this.id,
    required this.name,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Serializa para Firestore (salva/atualiza)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Constrói a partir de DocumentSnapshot do Firestore
  factory ServiceType.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceType(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  /// Constrói a partir de Map<String, dynamic> (aninhado em Project)
  factory ServiceType.fromMap(Map<String, dynamic> map) {
    return ServiceType(
      id: map['id'],
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  /// Para criar/atualizar localmente
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

  // ------- Adicione este trecho para correção do Dropdown -------
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ServiceType &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => (id ?? name).hashCode;
// --------------------------------------------------------------
}