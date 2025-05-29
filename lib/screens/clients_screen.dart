import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/client.dart';
import '../providers/client_provider.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final provider = Provider.of<ClientProvider>(context, listen: false);
    await provider.loadClients();
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("Clientes"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1C),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título e explicação
              Text(
                "Gerencie seus clientes",
                style: theme.textTheme.titleLarge!.copyWith(
                  color: const Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Cadastre novos clientes e acompanhe sua lista.",
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFF6E6E73),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 18),

              // Campo de adicionar novo cliente
              Material(
                elevation: 0.5,
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(fontFamily: 'Inter'),
                          decoration: InputDecoration(
                            hintText: "Digite o nome do cliente",
                            fillColor: const Color(0xFFF9F9FB),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                            ),
                          ),
                          onSubmitted: (val) async {
                            if (val.trim().isNotEmpty) {
                              await clientProvider.addClient(Client(name: val.trim()));
                              _controller.clear();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E60CE),
                          foregroundColor: const Color(0xFFF9F9FB),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 22),
                        label: const Text("Adicionar"),
                        onPressed: () async {
                          final name = _controller.text.trim();
                          if (name.isNotEmpty) {
                            await clientProvider.addClient(Client(name: name));
                            _controller.clear();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // Lista de clientes
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : clientProvider.clients.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, size: 44, color: Colors.grey[300]),
                      const SizedBox(height: 10),
                      Text(
                        "Nenhum cliente cadastrado ainda.",
                        style: TextStyle(
                          color: const Color(0xFF6E6E73),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: clientProvider.clients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final client = clientProvider.clients[index];
                    return Material(
                      color: Colors.white,
                      elevation: 0.5,
                      borderRadius: BorderRadius.circular(10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF5E60CE).withOpacity(0.13),
                          foregroundColor: const Color(0xFF5E60CE),
                          child: const Icon(Icons.person),
                        ),
                        title: Text(
                          client.name,
                          style: const TextStyle(
                            color: Color(0xFF1C1C1C),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                        ),
                        subtitle: client.email != null && client.email!.isNotEmpty
                            ? Text(client.email!,
                            style: const TextStyle(
                                color: Color(0xFF6E6E73),
                                fontFamily: 'Inter'))
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEA6C66)),
                          tooltip: "Remover cliente",
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Remover cliente"),
                                content: Text("Tem certeza que deseja remover '${client.name}' da lista?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancelar"),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEA6C66),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text("Remover"),
                                    onPressed: () async {
                                      await clientProvider.removeClient(client);
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
