import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String content;
  final String author;

  Quote({required this.content, required this.author});
}

class QuoteService {
  static Future<Quote> fetchRandomQuote() async {
    final url = Uri.parse('https://zenquotes.io/api/random');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      final q = data[0];
      return Quote(content: q['q'] ?? '', author: q['a'] ?? 'Autor desconhecido');
    } else {
      throw Exception("Erro ao buscar frase");
    }
  }
}
