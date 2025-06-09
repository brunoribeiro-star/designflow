import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../models/client.dart';
import '../models/service_type.dart';
import '../providers/project_provider.dart';
import '../providers/client_provider.dart';
import '../providers/service_type_provider.dart';

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({Key? key}) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late Project _project;
  late TextEditingController _nameController;
  late DateTime _deadline;
  Client? _selectedClient;
  ServiceType? _selectedServiceType;

  List<ChecklistItem> _initialChecklist = [];
  List<ChecklistItem> _executionChecklist = [];
  final TextEditingController _newChecklistItemController = TextEditingController();

  bool _loading = true;

  @override
  void dispose() {
    _nameController.dispose();
    _newChecklistItemController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    _project = ModalRoute.of(context)!.settings.arguments as Project;

    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(context, listen: false);

    if (clientProvider.clients.isEmpty) await clientProvider.loadClients();
    if (serviceTypeProvider.serviceTypes.isEmpty) await serviceTypeProvider.loadServiceTypes();

    _nameController = TextEditingController(text: _project.name);
    _deadline = _project.deadline;

    _selectedClient = clientProvider.clients
        .where((c) => c.id == _project.client.id)
        .cast<Client?>()
        .firstWhere((c) => c != null, orElse: () => null);
    _selectedClient ??= clientProvider.clients.isNotEmpty ? clientProvider.clients.first : null;

    _selectedServiceType = serviceTypeProvider.serviceTypes
        .where((s) => s.id == _project.serviceType.id)
        .cast<ServiceType?>()
        .firstWhere((s) => s != null, orElse: () => null);
    _selectedServiceType ??= serviceTypeProvider.serviceTypes.isNotEmpty ? serviceTypeProvider.serviceTypes.first : null;

    _initialChecklist = List<ChecklistItem>.from(
      _project.checklist.map((c) => ChecklistItem(title: c.title, isDone: c.isDone)),
    );
    _executionChecklist = List<ChecklistItem>.from(
      _project.executionChecklist.map((c) => ChecklistItem(title: c.title, isDone: c.isDone)),
    );
    setState(() {
      _loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadInitialData();
    }
  }

  void _addChecklistItem(List<ChecklistItem> checklist, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        checklist.add(ChecklistItem(title: text, isDone: false));
        controller.clear();
      });
    }
  }

  void _removeChecklistItem(List<ChecklistItem> checklist, int idx) {
    setState(() {
      checklist.removeAt(idx);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate() || _selectedClient == null || _selectedServiceType == null) return;

    final editedProject = _project.copyWith(
      name: _nameController.text.trim(),
      client: _selectedClient!,
      serviceType: _selectedServiceType!,
      checklist: _project.status == ProjectStatus.notStarted ? _initialChecklist : _project.checklist,
      executionChecklist: _project.status == ProjectStatus.inProgress ? _executionChecklist : _project.executionChecklist,
    );

    Provider.of<ProjectProvider>(context, listen: false).updateProject(_project, editedProject);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Projeto atualizado com sucesso!"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(context);

    if (_loading ||
        clientProvider.clients.isEmpty ||
        serviceTypeProvider.serviceTypes.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF5E60CE);
    final cancelBorder = primaryColor.withOpacity(0.12);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Projeto"),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 470),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Editar Projeto",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                        color: primaryColor,
                        letterSpacing: -1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nome do Projeto",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: "Ex: Redesign da Logo",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Cliente",
                        style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      items: clientProvider.clients
                          .map((client) => DropdownMenuItem(value: client, child: Text(client.name)))
                          .toList(),
                      onChanged: (client) => setState(() => _selectedClient = client),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) => value == null ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tipo de Serviço",
                        style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ServiceType>(
                      value: _selectedServiceType,
                      items: serviceTypeProvider.serviceTypes
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.name)))
                          .toList(),
                      onChanged: (type) => setState(() => _selectedServiceType = type),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      validator: (value) => value == null ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 30),
                    if (_project.status == ProjectStatus.notStarted) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Checklist Inicial",
                          style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          for (int i = 0; i < _initialChecklist.length; i++)
                            Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                title: Text(_initialChecklist[i].title),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEA6C66)),
                                  onPressed: () => _removeChecklistItem(_initialChecklist, i),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newChecklistItemController,
                                  decoration: const InputDecoration(
                                    hintText: "Adicionar novo item",
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _addChecklistItem(_initialChecklist, _newChecklistItemController),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () => _addChecklistItem(_initialChecklist, _newChecklistItemController),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (_project.status == ProjectStatus.inProgress) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Checklist de Execução",
                          style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          for (int i = 0; i < _executionChecklist.length; i++)
                            Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              child: ListTile(
                                title: Text(_executionChecklist[i].title),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEA6C66)),
                                  onPressed: () => _removeChecklistItem(_executionChecklist, i),
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _newChecklistItemController,
                                  decoration: const InputDecoration(
                                    hintText: "Adicionar novo item",
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (_) => _addChecklistItem(_executionChecklist, _newChecklistItemController),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                ),
                                onPressed: () => _addChecklistItem(_executionChecklist, _newChecklistItemController),
                                child: const Icon(Icons.add, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 26),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                                elevation: 0,
                              ),
                              onPressed: _onSave,
                              icon: const Icon(Icons.check, color: Colors.white),
                              label: const Text("Salvar"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(color: cancelBorder, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 26),
                                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancelar"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}