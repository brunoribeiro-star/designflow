import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';
import '../models/client.dart';
import '../models/service_type.dart';

// Lembre de adicionar o pacote sqflite e path no pubspec.yaml

class DBService {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'designer_organizer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela de clientes
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT,
            phone TEXT,
            createdAt TEXT NOT NULL
          )
        ''');

        // Tabela de tipos de serviço
        await db.execute('''
          CREATE TABLE service_types (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');

        // Tabela de projetos
        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            clientId INTEGER NOT NULL,
            serviceTypeId INTEGER NOT NULL,
            deadline TEXT NOT NULL,
            status INTEGER NOT NULL,
            isPaid INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY(clientId) REFERENCES clients(id),
            FOREIGN KEY(serviceTypeId) REFERENCES service_types(id)
          )
        ''');

        // Tabela de checklist
        await db.execute('''
          CREATE TABLE checklist_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            projectId INTEGER NOT NULL,
            title TEXT NOT NULL,
            isDone INTEGER NOT NULL,
            FOREIGN KEY(projectId) REFERENCES projects(id)
          )
        ''');

        // Tabela de pagamentos
        await db.execute('''
          CREATE TABLE payment_info (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            projectId INTEGER NOT NULL,
            method INTEGER NOT NULL,
            installments INTEGER,
            paidInitial INTEGER,
            paidFinal INTEGER,
            FOREIGN KEY(projectId) REFERENCES projects(id)
          )
        ''');
      },
    );
  }

  // Métodos para salvar e buscar clientes
  static Future<int> insertClient(Client client) async {
    final dbClient = await db;
    return await dbClient.insert('clients', client.toMap());
  }

  static Future<List<Client>> getClients() async {
    final dbClient = await db;
    final result = await dbClient.query('clients');
    return result.map((map) => Client.fromMap(map)).toList();
  }

  // Métodos para service types
  static Future<int> insertServiceType(ServiceType type) async {
    final dbClient = await db;
    // Troque toMap() por toFirestore()
    return await dbClient.insert('service_types', type.toFirestore());
  }

  static Future<List<ServiceType>> getServiceTypes() async {
    final dbClient = await db;
    final result = await dbClient.query('service_types');
    // Troque ServiceType.fromMap por factory igual do Firebase:
    return result.map((map) => ServiceType.fromMap(map)).toList();
  }

  // Métodos para projetos
  static Future<int> insertProject(Project project) async {
    final dbClient = await db;
    // Troque toMap() por toFirestore()
    return await dbClient.insert('projects', project.toFirestore());
  }

  static Future<List<Project>> getProjects({
    required List<Client> clients,
    required List<ServiceType> serviceTypes,
  }) async {
    final dbClient = await db;
    final result = await dbClient.query('projects');

    // Pega checklist e pagamento de cada projeto
    List<Project> projects = [];
    for (var map in result) {
      final int clientId = int.parse(map['clientId'].toString());
      final int serviceTypeId = int.parse(map['serviceTypeId'].toString());
      final int projectId = int.parse(map['id'].toString());

      final client = clients.firstWhere((c) => c.id == clientId);
      final serviceType = serviceTypes.firstWhere((s) => s.id == serviceTypeId);
      final checklist = await getChecklistItems(projectId);
      final payment = await getPaymentInfo(projectId);

      // Use a factory que aceita Map:
      projects.add(Project.fromMap(
        map,
        client,
        serviceType,
        checklist,
        payment,
      ));
    }
    return projects;
  }

  // Checklist
  static Future<int> insertChecklistItem(ChecklistItem item) async {
    final dbClient = await db;
    return await dbClient.insert('checklist_items', item.toMap());
  }

  static Future<List<ChecklistItem>> getChecklistItems(int projectId) async {
    final dbClient = await db;
    final result =
    await dbClient.query('checklist_items', where: 'projectId = ?', whereArgs: [projectId]);
    return result.map((map) => ChecklistItem.fromMap(map)).toList();
  }

  // Payment Info
  static Future<int> insertPaymentInfo(PaymentInfo payment, int projectId) async {
    final dbClient = await db;
    final map = payment.toMap()..addAll({'projectId': projectId});
    return await dbClient.insert('payment_info', map);
  }

  static Future<PaymentInfo> getPaymentInfo(int projectId) async {
    final dbClient = await db;
    final result = await dbClient.query('payment_info',
        where: 'projectId = ?', whereArgs: [projectId]);
    if (result.isNotEmpty) {
      return PaymentInfo.fromMap(result.first);
    }
    // Retorna dummy se não houver registro (proteção)
    return PaymentInfo(method: PaymentMethod.card, installments: 1);
  }

// Outros métodos de update e delete podem ser adicionados conforme necessário.
}