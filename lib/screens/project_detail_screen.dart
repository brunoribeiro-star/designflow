import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({super.key});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late Project project;

  // Controle para criação do checklist de execução
  bool showCreateExecutionChecklistDialog = false;
  final TextEditingController _executionChecklistController = TextEditingController();
  List<ChecklistItem> _executionChecklistDraft = [];

  @override
  void dispose() {
    _executionChecklistController.dispose();
    super.dispose();
  }

  void _checkChecklistStatus() async {
    if (project.status == ProjectStatus.notStarted &&
        project.checklist.isNotEmpty &&
        project.checklist.every((item) => item.isDone)) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Checklist inicial concluído!"),
          content: const Text(
              "Tudo que precisava para iniciar o projeto foi feito. Agora você precisa criar o checklist de execução do projeto antes de sair."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Criar checklist de execução"),
            ),
          ],
        ),
      );
      setState(() {
        showCreateExecutionChecklistDialog = true;
      });
      // Altera status para EM ANDAMENTO
      project.status = ProjectStatus.inProgress;
      Provider.of<ProjectProvider>(context, listen: false)
          .changeStatus(project, ProjectStatus.inProgress);
    }
  }

  void _checkExecutionChecklistStatus() async {
    if (project.status == ProjectStatus.inProgress &&
        project.executionChecklist.isNotEmpty &&
        project.executionChecklist.every((item) => item.isDone)) {
      bool isPagamentoOK = false;

      if ((project.payment.method == PaymentMethod.pixSplit &&
          project.payment.paidFinal) ||
          (project.payment.method != PaymentMethod.pixSplit && project.isPaid)) {
        isPagamentoOK = true;
      }

      if (isPagamentoOK) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Projeto Finalizado!"),
            content: const Text(
                "Todas as etapas do projeto foram concluídas e o pagamento está em dia. Projeto finalizado com sucesso!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        setState(() {
          project.status = ProjectStatus.finished;
        });
        Provider.of<ProjectProvider>(context, listen: false)
            .changeStatus(project, ProjectStatus.finished);
      } else {
        bool pagamentoFeito = false;
        await showDialog(
          context: context,
          builder: (ctx) {
            bool _localChecked = false;
            return StatefulBuilder(
              builder: (ctx, setDialogState) => AlertDialog(
                title: const Text("Pagamento pendente"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Todas as etapas foram concluídas, mas falta o cliente realizar o pagamento final."),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _localChecked,
                      onChanged: (val) {
                        setDialogState(() => _localChecked = val ?? false);
                      },
                      title: const Text("Cliente pagou o restante"),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton(
                    onPressed: _localChecked
                        ? () {
                      pagamentoFeito = true;
                      Navigator.of(ctx).pop();
                    }
                        : null,
                    child: const Text("Finalizar projeto"),
                  ),
                ],
              ),
            );
          },
        );
        if (pagamentoFeito) {
          setState(() {
            if (project.payment.method == PaymentMethod.pixSplit) {
              project.payment.paidFinal = true;
            } else {
              project.isPaid = true;
            }
            project.status = ProjectStatus.finished;
          });
          Provider.of<ProjectProvider>(context, listen: false)
              .changeStatus(project, ProjectStatus.finished);
        }
      }
    }
  }

  // --- BLOQUEIO DE SAÍDA ---
  Future<bool> _handleWillPop() async {
    if (showCreateExecutionChecklistDialog && project.executionChecklist.isEmpty) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Checklist obrigatório"),
          content: const Text(
              "Por favor, preencha o checklist das próximas etapas antes de sair."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return false; // bloqueia saída
    }
    return true; // libera saída
  }

  @override
  Widget build(BuildContext context) {
    project = ModalRoute.of(context)!.settings.arguments as Project;

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cliente: ${project.client.name}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text("Tipo de Serviço: ${project.serviceType.name}"),
                const SizedBox(height: 12),
                Text(
                    "Data de entrega: ${project.deadline.day}/${project.deadline.month}/${project.deadline.year}"),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Status do Projeto: "),
                    Text(
                      project.status == ProjectStatus.notStarted
                          ? "Não iniciado"
                          : project.status == ProjectStatus.inProgress
                          ? "Em andamento"
                          : "Finalizado",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (project.payment.method == PaymentMethod.pixSplit) ...[
                  Row(
                    children: [
                      const Text("Pagamento: "),
                      Text(
                        project.payment.paidInitial
                            ? "50% iniciais pagos"
                            : "Aguardando 50% iniciais",
                        style: TextStyle(
                            color: project.payment.paidInitial ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text("Restante: "),
                      Text(
                        project.payment.paidFinal
                            ? "50% finais pagos"
                            : "Aguardando 50% finais (na entrega)",
                        style: TextStyle(
                            color: project.payment.paidFinal ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      const Text("Pagamento: "),
                      Text(project.isPaid ? "Concluído" : "Pendente",
                          style: TextStyle(
                              color: project.isPaid ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                const SizedBox(height: 18),

                // CHECKLISTS
                if (project.status == ProjectStatus.notStarted &&
                    project.executionChecklist.isEmpty)
                  ...[
                    const Text("Checklist Inicial"),
                    project.checklist.isEmpty
                        ? const Text("Sem tarefas ainda.")
                        : Column(
                      children: project.checklist
                          .asMap()
                          .entries
                          .map(
                            (entry) => CheckboxListTile(
                          value: entry.value.isDone,
                          onChanged: (val) {
                            setState(() {
                              entry.value.isDone = val ?? false;
                            });
                            _checkChecklistStatus();
                          },
                          title: Text(entry.value.title),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      )
                          .toList(),
                    ),
                  ]
                else if (showCreateExecutionChecklistDialog &&
                    project.executionChecklist.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Checklist de Execução do Projeto",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _executionChecklistController,
                              decoration:
                              const InputDecoration(hintText: "Adicionar etapa"),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (_executionChecklistController.text.trim().isNotEmpty) {
                                setState(() {
                                  _executionChecklistDraft.add(
                                    ChecklistItem(
                                        title:
                                        _executionChecklistController.text.trim()),
                                  );
                                  _executionChecklistController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      if (_executionChecklistDraft.isNotEmpty)
                        ..._executionChecklistDraft
                            .map((item) => ListTile(
                          leading: const Icon(Icons.check_box_outline_blank),
                          title: Text(item.title),
                        ))
                            .toList(),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _executionChecklistDraft.isEmpty
                            ? null
                            : () {
                          setState(() {
                            project.executionChecklist =
                                List.from(_executionChecklistDraft);
                            showCreateExecutionChecklistDialog = false;
                            _executionChecklistDraft.clear();
                          });
                        },
                        child: const Text("Salvar checklist do projeto"),
                      ),
                    ],
                  )
                else if (project.executionChecklist.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Checklist de Execução do Projeto",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...project.executionChecklist.asMap().entries.map(
                              (entry) => CheckboxListTile(
                            value: entry.value.isDone,
                            onChanged: (val) {
                              setState(() {
                                entry.value.isDone = val ?? false;
                              });
                              _checkExecutionChecklistStatus();
                            },
                            title: Text(entry.value.title),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: 22),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // No futuro: editar projeto, checklist, etc.
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Função de edição/checklist será implementada.'),
                      ));
                    },
                    child: const Text("Editar/Atualizar Projeto"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}