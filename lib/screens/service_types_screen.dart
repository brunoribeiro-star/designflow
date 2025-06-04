import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service_type.dart';
import '../providers/service_type_provider.dart';

class ServiceTypesScreen extends StatefulWidget {
  const ServiceTypesScreen({super.key});

  @override
  State<ServiceTypesScreen> createState() => _ServiceTypesScreenState();
}

class _ServiceTypesScreenState extends State<ServiceTypesScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = Provider.of<ServiceTypeProvider>(context, listen: false).loadServiceTypes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addServiceType(ServiceTypeProvider provider) async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    // Evita duplicados
    if (provider.serviceTypes.any((st) => st.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Este tipo de serviço já existe!")),
      );
      return;
    }
    await provider.addServiceType(ServiceType(name: name));
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Serviço"),
      ),
      body: FutureBuilder<void>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          final serviceTypeProvider = Provider.of<ServiceTypeProvider>(context);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          labelText: "Novo tipo de serviço",
                        ),
                        onSubmitted: (_) => _addServiceType(serviceTypeProvider),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addServiceType(serviceTypeProvider),
                    )
                  ],
                ),
              ),
              Expanded(
                child: serviceTypeProvider.serviceTypes.isEmpty
                    ? const Center(child: Text("Nenhum tipo cadastrado."))
                    : ListView.builder(
                  itemCount: serviceTypeProvider.serviceTypes.length,
                  itemBuilder: (context, index) {
                    final st = serviceTypeProvider.serviceTypes[index];
                    return ListTile(
                      leading: const Icon(Icons.design_services),
                      title: Text(st.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Remover tipo de serviço"),
                              content: Text("Deseja remover '${st.name}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEA6C66),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text("Remover"),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await serviceTypeProvider.removeServiceType(st);
                          }
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}