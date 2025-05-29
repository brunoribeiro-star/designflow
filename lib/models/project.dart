import 'client.dart';
import 'service_type.dart';

enum ProjectStatus { notStarted, inProgress, finished }

class Project {
  String? id; // Firestore docId ou SQLite id (string)
  String name;
  Client client;
  ServiceType serviceType;
  DateTime deadline;
  ProjectStatus status;
  List<ChecklistItem> checklist;           // Checklist inicial
  List<ChecklistItem> executionChecklist;  // Checklist das etapas do projeto
  PaymentInfo payment;
  bool isPaid;
  DateTime createdAt;

  Project({
    this.id,
    required this.name,
    required this.client,
    required this.serviceType,
    required this.deadline,
    required this.status,
    required this.checklist,
    this.executionChecklist = const [],
    required this.payment,
    this.isPaid = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Para cores de prazo
  String get deadlineStatus {
    final now = DateTime.now();
    final difference = deadline.difference(now).inDays;
    if (difference > 5) return 'green';
    if (difference > 1) return 'yellow';
    return 'red';
  }

  /// ---------- SERIALIZAÇÃO PARA FIRESTORE ----------
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'client': client.toFirestore(),
      'serviceType': serviceType.toFirestore(),
      'deadline': deadline.toIso8601String(),
      'status': status.index,
      'checklist': checklist.map((item) => item.toMap()).toList(),
      'executionChecklist': executionChecklist.map((item) => item.toMap()).toList(),
      'payment': payment.toMap(),
      'isPaid': isPaid,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Project.fromFirestore(dynamic doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      name: map['name'] ?? '',
      client: Client.fromMap(Map<String, dynamic>.from(map['client'] ?? {})),
      serviceType: ServiceType.fromMap(
        Map<String, dynamic>.from(map['serviceType'] ?? {}),
      ),
      deadline: DateTime.parse(map['deadline'] ?? DateTime.now().toIso8601String()),
      status: ProjectStatus.values[map['status'] ?? 0],
      checklist: (map['checklist'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      executionChecklist: (map['executionChecklist'] as List<dynamic>? ?? [])
          .map((item) => ChecklistItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      payment: PaymentInfo.fromMap(Map<String, dynamic>.from(map['payment'] ?? {})),
      isPaid: (map['isPaid'] is bool) ? map['isPaid'] : (map['isPaid'] ?? false) == 1,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// ---------- SERIALIZAÇÃO PARA SQLite/local ----------
  // Lembre: aqui, client, serviceType, checklist e payment já vêm prontos das consultas relacionadas
  factory Project.fromMap(
      Map<String, dynamic> map,
      Client client,
      ServiceType serviceType,
      List<ChecklistItem> checklist,
      PaymentInfo payment, {
        List<ChecklistItem>? executionChecklist,
      }) {
    return Project(
      id: map['id']?.toString(),
      name: map['name'] ?? '',
      client: client,
      serviceType: serviceType,
      deadline: DateTime.parse(map['deadline']),
      status: ProjectStatus.values[map['status'] ?? 0],
      checklist: checklist,
      executionChecklist: executionChecklist ?? [],
      payment: payment,
      isPaid: map['isPaid'] == 1 || map['isPaid'] == true,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// Checklist adaptado para Firestore/SQLite
class ChecklistItem {
  String? id;
  String? projectId;
  String title;
  bool isDone;

  ChecklistItem({
    this.id,
    this.projectId,
    required this.title,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'isDone': isDone,
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id']?.toString(),
      projectId: map['projectId']?.toString(),
      title: map['title'] ?? '',
      isDone: (map['isDone'] is bool) ? map['isDone'] : (map['isDone'] ?? false) == 1,
    );
  }
}

// Pagamento
enum PaymentMethod { card, pixSingle, pixSplit }

class PaymentInfo {
  PaymentMethod method;
  int? installments; // Só para cartão
  bool paidInitial; // Para Pix 2x
  bool paidFinal; // Para Pix 2x

  PaymentInfo({
    required this.method,
    this.installments,
    this.paidInitial = false,
    this.paidFinal = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'method': method.index,
      'installments': installments,
      'paidInitial': paidInitial,
      'paidFinal': paidFinal,
    };
  }

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    int? installments;
    if (map['installments'] is int) {
      installments = map['installments'];
    } else if (map['installments'] is String) {
      installments = int.tryParse(map['installments']);
    }

    return PaymentInfo(
      method: PaymentMethod.values[map['method'] ?? 0],
      installments: installments,
      paidInitial: (map['paidInitial'] is bool)
          ? map['paidInitial']
          : (map['paidInitial'] ?? false) == 1,
      paidFinal: (map['paidFinal'] is bool)
          ? map['paidFinal']
          : (map['paidFinal'] ?? false) == 1,
    );
  }
}