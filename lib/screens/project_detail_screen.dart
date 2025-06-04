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
      return false;
    }
    return true;
  }

  Widget _buildStatusChip(ProjectStatus status) {
    Color color;
    IconData icon;
    String text;
    switch (status) {
      case ProjectStatus.notStarted:
        color = Colors.orange[600]!;
        icon = Icons.access_time_rounded;
        text = "Não iniciado";
        break;
      case ProjectStatus.inProgress:
        color = Colors.blue[700]!;
        icon = Icons.play_arrow_rounded;
        text = "Em andamento";
        break;
      case ProjectStatus.finished:
        color = Colors.green[600]!;
        icon = Icons.check_circle_rounded;
        text = "Finalizado";
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
        text = "Desconhecido";
    }
    return Chip(
      avatar: Icon(icon, color: Colors.white, size: 20),
      backgroundColor: color,
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }

  Widget _buildPaymentStatus() {
    final styleBold = const TextStyle(fontWeight: FontWeight.bold, fontSize: 15);
    final stylePaid = styleBold.copyWith(color: Colors.green[700]);
    final stylePending = styleBold.copyWith(color: Colors.red[400]);
    if (project.payment.method == PaymentMethod.pixSplit) {
      return Column(
        children: [
          Row(
            children: [
              Icon(Icons.payments_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text("Pagamento: ", style: styleBold),
              Text(
                project.payment.paidInitial ? "50% iniciais pagos" : "Aguardando 50% iniciais",
                style: project.payment.paidInitial ? stylePaid : stylePending,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 28),
              Text("Restante: ", style: styleBold),
              Text(
                project.payment.paidFinal ? "50% finais pagos" : "Aguardando 50% finais (na entrega)",
                style: project.payment.paidFinal ? stylePaid : stylePending,
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.payments_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Text("Pagamento: ", style: styleBold),
          Text(
            project.isPaid ? "Concluído" : "Pendente",
            style: project.isPaid ? stylePaid : stylePending,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    project = ModalRoute.of(context)!.settings.arguments as Project;
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _handleWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Projeto'),
          automaticallyImplyLeading: true,
          backgroundColor: const Color(0xFF5E60CE),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME DO PROJETO (maior destaque)
                Text(
                  project.name,
                  style: theme.textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 10),

                // STATUS DO PROJETO (chip colorido)
                _buildStatusChip(project.status),
                const SizedBox(height: 16),

                // DADOS PRINCIPAIS
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.person, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(project.client.name,
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.design_services_rounded, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(project.serviceType.name,
                        style: theme.textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.event, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Entrega: ${project.deadline.day.toString().padLeft(2, '0')}/${project.deadline.month.toString().padLeft(2, '0')}/${project.deadline.year}",
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // PAGAMENTO (destacado se pendente)
                _buildPaymentStatus(),
                const SizedBox(height: 22),

                // --- CHECKLISTS EM CARDS ---
                if (project.status == ProjectStatus.notStarted &&
                    project.executionChecklist.isEmpty) ...[
                  Text("Checklist Inicial",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      )),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: project.checklist.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Sem tarefas ainda.", style: TextStyle(color: Colors.grey)),
                      )
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
                    ),
                  ),
                ] else if (showCreateExecutionChecklistDialog &&
                    project.executionChecklist.isEmpty) ...[
                  Text(
                    "Checklist de Execução do Projeto",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _executionChecklistController,
                          decoration: const InputDecoration(hintText: "Adicionar etapa"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_executionChecklistController.text.trim().isNotEmpty) {
                            setState(() {
                              _executionChecklistDraft.add(
                                ChecklistItem(
                                    title: _executionChecklistController.text.trim()),
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
                ] else if (project.executionChecklist.isNotEmpty) ...[
                  Text(
                    "Checklist de Execução do Projeto",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        children: project.executionChecklist.asMap().entries.map(
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
                        ).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Mais espaço inferior para UX mobile
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}