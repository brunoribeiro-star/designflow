class Client {
  String? id; // <- Para firestore use String
  String name;
  String? email;
  String? phone;
  DateTime createdAt;

  Client({
    this.id,
    required this.name,
    this.email,
    this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Serialização para firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Desserialização do firestore
  factory Client.fromFirestore(dynamic doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Local, se precisar
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}