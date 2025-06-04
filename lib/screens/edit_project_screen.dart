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

  // Para checklist
  List<ChecklistItem> _initialChecklist = [];
  List<ChecklistItem> _executionChecklist = [];
  final TextEditingController _newChecklistItemController = TextEditingController();

  bool _isLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _newChecklistItemController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      _project = ModalRoute.of(context)!.settings.arguments as Project;
      _nameController = TextEditingController(text: _project.name);
      _deadline = _project.deadline;
      _selectedClient = _project.client;
      _selectedServiceType = _project.serviceType;
      _initialChecklist = List<ChecklistItem>.from(
        _project.checklist.map((c) => ChecklistItem(title: c.title, isDone: c.isDone)),
      );
      _executionChecklist = List<ChecklistItem>.from(
        _project.executionChecklist.map((c) => ChecklistItem(title: c.title, isDone: c.isDone)),
      );
      _isLoaded = true;
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
      // deadline removido da edição!
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
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final clientProvider = Provider.of<ClientProvider>(context);
    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Projeto"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do Projeto
              Text("Nome do Projeto", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Ex: Redesign da Logo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? "Campo obrigatório" : null,
              ),
              const SizedBox(height: 18),

              // Cliente
              Text("Cliente", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 18),

              // Tipo de Serviço
              Text("Tipo de Serviço", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
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
              const SizedBox(height: 22),

              // Checklist Inicial
              if (_project.status == ProjectStatus.notStarted) ...[
                Text("Checklist Inicial", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
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
                            backgroundColor: const Color(0xFF5E60CE),
                          ),
                          onPressed: () => _addChecklistItem(_initialChecklist, _newChecklistItemController),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],

              // Checklist de Execução
              if (_project.status == ProjectStatus.inProgress) ...[
                Text("Checklist de Execução", style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
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
                            backgroundColor: const Color(0xFF5E60CE),
                          ),
                          onPressed: () => _addChecklistItem(_executionChecklist, _newChecklistItemController),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],

              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E60CE),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onPressed: _onSave,
                      icon: const Icon(Icons.check),
                      label: const Text("Salvar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}