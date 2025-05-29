import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/client.dart';

// Exemplo simples de GET/POST de clientes

class ApiService {
  static const String baseUrl = "https://jsonplaceholder.typicode.com"; // Você pode trocar por um endpoint real ou mock

  // GET - Buscar "clientes" fake (simulação)
  static Future<List<Client>> fetchClients() async {
    final response = await http.get(Uri.parse("$baseUrl/users"));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => Client(
        id: item['id'],
        name: item['name'],
        email: item['email'],
      )).toList();
    } else {
      throw Exception("Erro ao buscar clientes na API.");
    }
  }

  // POST - Adicionar cliente (simulação)
  static Future<bool> addClient(Client client) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(client.toMap()),
    );
    return response.statusCode == 201;
  }
}
