import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/project.dart';
import '../models/client.dart';
import '../models/service_type.dart';
import '../providers/project_provider.dart';
import '../providers/client_provider.dart';
import '../providers/service_type_provider.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final TextEditingController _checklistController = TextEditingController();
  Client? _selectedClient;
  ServiceType? _selectedServiceType;
  DateTime? _selectedDeadline;
  bool _isPaid = false;
  bool _paidInitial = false;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;
  int _installments = 1;

  // Para armazenar itens do checklist inicial
  List<ChecklistItem> _checklist = [];

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final serviceTypeProvider = Provider.of<ServiceTypeProvider>(context);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        title: const Text("Novo Projeto"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1C),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 470),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      "Adicionar Novo Projeto",
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: const Color(0xFF1C1C1C),
                        fontWeight: FontWeight.w600,
                        fontFamily: "Inter",
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nome do Projeto
                    Text(
                      "Nome do Projeto",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(fontFamily: "Inter"),
                      decoration: InputDecoration(
                        hintText: "Ex: Branding para Padaria Estilo",
                        filled: true,
                        fillColor: const Color(0xFFF9F9FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? "Campo obrigatório" : null,
                    ),
                    const SizedBox(height: 20),

                    // Cliente
                    Text(
                      "Cliente",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      hint: const Text("Selecione o cliente"),
                      icon: const Icon(Icons.expand_more_rounded),
                      decoration: _dropdownDecoration(),
                      items: clientProvider.clients
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (c) => setState(() => _selectedClient = c),
                      validator: (value) => value == null ? "Selecione um cliente" : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5E60CE),
                        ),
                        onPressed: () async {
                          final name = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                String tempName = '';
                                return AlertDialog(
                                  title: const Text("Adicionar Cliente"),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Nome do Cliente",
                                    ),
                                    onChanged: (val) => tempName = val,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(tempName),
                                        child: const Text("Adicionar")),
                                  ],
                                );
                              });
                          if (name != null && name.isNotEmpty) {
                            final newClient =
                            Client(name: name, createdAt: DateTime.now());
                            await clientProvider.addClient(newClient);
                            // Aguarda recarregar lista de clientes (opcional)
                            await clientProvider.loadClients();
                            setState(() {
                              _selectedClient = clientProvider.findByName(name);
                            });
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Novo Cliente"),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo de Serviço
                    Text(
                      "Tipo de Serviço",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<ServiceType>(
                      value: _selectedServiceType,
                      hint: const Text("Selecione o tipo de serviço"),
                      icon: const Icon(Icons.expand_more_rounded),
                      decoration: _dropdownDecoration(),
                      items: serviceTypeProvider.serviceTypes
                          .map((st) =>
                          DropdownMenuItem(value: st, child: Text(st.name)))
                          .toList(),
                      onChanged: (st) => setState(() => _selectedServiceType = st),
                      validator: (value) =>
                      value == null ? "Selecione um tipo de serviço" : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF5E60CE),
                        ),
                        onPressed: () async {
                          final name = await showDialog<String>(
                              context: context,
                              builder: (ctx) {
                                String tempName = '';
                                return AlertDialog(
                                  title: const Text("Adicionar Tipo de Serviço"),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                      labelText: "Nome do Tipo",
                                    ),
                                    onChanged: (val) => tempName = val,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: const Text("Cancelar")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(tempName),
                                        child: const Text("Adicionar")),
                                  ],
                                );
                              });
                          if (name != null && name.isNotEmpty) {
                            final newType =
                            ServiceType(name: name, createdAt: DateTime.now());
                            await serviceTypeProvider.addServiceType(newType);
                            // Aguarda recarregar a lista para garantir seleção correta
                            await serviceTypeProvider.fetchServiceTypes();
                            setState(() {
                              // Busca a instância correta na lista atualizada (por nome)
                              _selectedServiceType =
                                  serviceTypeProvider.findByName(name);
                            });
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Novo Tipo"),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Data de entrega
                    Text(
                      "Data de Entrega",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDeadline == null
                                ? "Nenhuma data selecionada"
                                : "${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}",
                            style: TextStyle(
                              color: _selectedDeadline == null
                                  ? const Color(0xFF6E6E73)
                                  : const Color(0xFF1C1C1C),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF5E60CE),
                          ),
                          child: const Text("Selecionar"),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 2),
                            );
                            if (picked != null) {
                              setState(() => _selectedDeadline = picked);
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Checklist inicial
                    Text(
                      "Checklist Inicial",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Adicione itens essenciais para iniciar o projeto. (Ex: Aprovação do briefing, Envio de documentos...)",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: const Color(0xFF6E6E73),
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _checklistController,
                            decoration: InputDecoration(
                              hintText: "Adicionar item...",
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
                            onSubmitted: (val) {
                              if (val.trim().isNotEmpty) {
                                setState(() {
                                  _checklist.add(ChecklistItem(title: val.trim()));
                                  _checklistController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              color: Color(0xFF5E60CE)),
                          onPressed: () {
                            if (_checklistController.text.trim().isNotEmpty) {
                              setState(() {
                                _checklist.add(
                                  ChecklistItem(title: _checklistController.text.trim()),
                                );
                                _checklistController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (_checklist.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          children: _checklist
                              .map((item) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_box_outline_blank_rounded,
                                color: Color(0xFF5E60CE), size: 22),
                            title: Text(item.title,
                                style: const TextStyle(
                                    color: Color(0xFF1C1C1C),
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500)),
                            contentPadding: EdgeInsets.zero,
                            minVerticalPadding: 0,
                          ))
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 28),

                    // Pagamento
                    Text(
                      "Forma de Pagamento",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<PaymentMethod>(
                      value: _selectedPaymentMethod,
                      decoration: _dropdownDecoration(),
                      items: PaymentMethod.values
                          .map((pm) => DropdownMenuItem(
                        value: pm,
                        child: Text(
                            pm == PaymentMethod.card
                                ? "Cartão de Crédito"
                                : pm == PaymentMethod.pixSingle
                                ? "Pix à vista"
                                : "Pix 2x (50%/50%)",
                            style: const TextStyle(fontFamily: 'Inter')),
                      ))
                          .toList(),
                      onChanged: (pm) {
                        setState(() {
                          _selectedPaymentMethod = pm!;
                          _isPaid = false;
                          _paidInitial = false;
                        });
                      },
                    ),
                    if (_selectedPaymentMethod == PaymentMethod.card) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("Parcelas:",
                              style: theme.textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 10),
                          DropdownButton<int>(
                            value: _installments,
                            items: List.generate(
                                12,
                                    (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text("${i + 1}x"),
                                )),
                            onChanged: (v) =>
                                setState(() => _installments = v ?? 1),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedPaymentMethod == PaymentMethod.pixSplit)
                      Row(
                        children: [
                          Checkbox(
                            value: _paidInitial,
                            activeColor: const Color(0xFF5E60CE),
                            onChanged: (v) =>
                                setState(() => _paidInitial = v ?? false),
                          ),
                          const Text("50% iniciais pagos"),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Checkbox(
                              value: _isPaid,
                              activeColor: const Color(0xFF5E60CE),
                              onChanged: (v) =>
                                  setState(() => _isPaid = v ?? false)),
                          const Text("Pago")
                        ],
                      ),
                    const SizedBox(height: 30),

                    // Salvar Projeto
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5E60CE),
                          foregroundColor: const Color(0xFFF9F9FB),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                            fontSize: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Salvar Projeto"),
                        onPressed: () {
                          if (_formKey.currentState?.validate() != true ||
                              _selectedDeadline == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Preencha todos os campos obrigatórios."),
                                ));
                            return;
                          }

                          // Monta os objetos auxiliares
                          final payment = PaymentInfo(
                            method: _selectedPaymentMethod,
                            installments: _selectedPaymentMethod == PaymentMethod.card
                                ? _installments
                                : null,
                            paidInitial: _selectedPaymentMethod == PaymentMethod.pixSplit
                                ? _paidInitial
                                : _isPaid,
                            paidFinal:
                            false, // o final será marcado no fechamento do projeto
                          );

                          final project = Project(
                            name: _nameController.text,
                            client: _selectedClient!,
                            serviceType: _selectedServiceType!,
                            deadline: _selectedDeadline!,
                            status: ProjectStatus.notStarted,
                            checklist: _checklist,
                            executionChecklist: [],
                            payment: payment,
                            isPaid: _isPaid,
                          );

                          projectProvider.addProject(project);
                          Navigator.pop(context);
                        },
                      ),
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF9F9FB),
      contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }
}