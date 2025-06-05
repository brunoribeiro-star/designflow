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

  final Color _primaryColor = const Color(0xFF5E60CE);
  final Color _borderColor = const Color(0x275E60CE); // roxo opaco

  @override
  void dispose() {
    _executionChecklistController.dispose();
    super.dispose();
  }

  // Estilo botão principal (roxo)
  ButtonStyle get _primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(110, 42),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  // Estilo botão cancelar (borda roxa opaca)
  ButtonStyle get _cancelButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: _primaryColor,
    side: BorderSide(color: _primaryColor.withOpacity(0.25), width: 2),
    minimumSize: const Size(110, 42),
    textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  // Usar esse para o único botão (OK, etc.)
  ButtonStyle get _singleFullButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: _primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(48),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  Future<void> _showStyledDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    required String mainLabel,
    VoidCallback? onMain,
    String? cancelLabel,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    bool mainEnabled = true,
    bool isSingleMain = false,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, textAlign: TextAlign.center),
        content: content,
        contentTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        actionsPadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
        actionsAlignment: isSingleMain ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
        actions: [
          if (isSingleMain)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: _singleFullButtonStyle,
                onPressed: mainEnabled ? onMain : null,
                child: Text(mainLabel),
              ),
            )
          else ...[
            // Ação principal (esquerda)
            ElevatedButton(
              style: _primaryButtonStyle,
              onPressed: mainEnabled ? onMain : null,
              child: Text(mainLabel),
            ),
            // Cancelar (direita)
            if (cancelLabel != null && onCancel != null)
              OutlinedButton(
                style: _cancelButtonStyle,
                onPressed: onCancel,
                child: Text(cancelLabel),
              ),
          ]
        ],
      ),
    );
  }

  void _checkChecklistStatus() async {
    if (project.status == ProjectStatus.notStarted &&
        project.checklist.isNotEmpty &&
        project.checklist.every((item) => item.isDone)) {
      await _showStyledDialog(
        context: context,
        title: "Checklist inicial concluído!",
        content: const Text(
          "Tudo que precisava para iniciar o projeto foi feito. Agora você precisa criar o checklist de execução do projeto antes de sair.",
          textAlign: TextAlign.center,
        ),
        mainLabel: "Criar checklist de execução",
        onMain: () => Navigator.of(context).pop(),
        isSingleMain: true,
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
        await _showStyledDialog(
          context: context,
          title: "Projeto Finalizado!",
          content: const Text(
            "Todas as etapas do projeto foram concluídas e o pagamento está em dia. Projeto finalizado com sucesso!",
            textAlign: TextAlign.center,
          ),
          mainLabel: "OK",
          onMain: () => Navigator.of(context).pop(),
          isSingleMain: true,
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
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Pagamento pendente", textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Todas as etapas foram concluídas, mas falta o cliente realizar o pagamento final.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _localChecked,
                    onChanged: (val) {
                      setState(() {});
                      (ctx as Element).markNeedsBuild();
                      _localChecked = val ?? false;
                    },
                    title: const Text("Cliente pagou o restante", textAlign: TextAlign.center),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                ElevatedButton(
                  style: _primaryButtonStyle,
                  onPressed: _localChecked
                      ? () {
                    pagamentoFeito = true;
                    Navigator.of(ctx).pop();
                  }
                      : null,
                  child: const Text("Finalizar projeto"),
                ),
                OutlinedButton(
                  style: _cancelButtonStyle,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Cancelar"),
                ),
              ],
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
      await _showStyledDialog(
        context: context,
        title: "Checklist obrigatório",
        content: const Text(
          "Por favor, preencha o checklist das próximas etapas antes de sair.",
          textAlign: TextAlign.center,
        ),
        mainLabel: "OK",
        onMain: () => Navigator.of(context).pop(),
        isSingleMain: true,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_outlined, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Pagamento: ", style: styleBold),
                      TextSpan(
                        text: project.payment.paidInitial
                            ? "50% iniciais pagos"
                            : "Aguardando 50% iniciais",
                        style: project.payment.paidInitial ? stylePaid : stylePending,
                      ),
                    ],
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: 0.0,
                child: Icon(Icons.payments_outlined, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Restante: ", style: styleBold),
                      TextSpan(
                        text: project.payment.paidFinal
                            ? "50% finais pagos"
                            : "Aguardando 50% finais (na entrega)",
                        style: project.payment.paidFinal ? stylePaid : stylePending,
                      ),
                    ],
                  ),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_outlined, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "Pagamento: ", style: styleBold),
                  TextSpan(
                    text: project.isPaid ? "Concluído" : "Pendente",
                    style: project.isPaid ? stylePaid : stylePending,
                  ),
                ],
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
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
          backgroundColor: _primaryColor,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 34),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // NOME DO PROJETO (maior destaque)
                      Text(
                        project.name,
                        style: theme.textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),

                      // STATUS DO PROJETO (chip colorido)
                      _buildStatusChip(project.status),
                      const SizedBox(height: 22),

                      // DADOS PRINCIPAIS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(project.client.name,
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.design_services_rounded, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(project.serviceType.name,
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event, size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            "Entrega: ${project.deadline.day.toString().padLeft(2, '0')}/${project.deadline.month.toString().padLeft(2, '0')}/${project.deadline.year}",
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // PAGAMENTO (centralizado e responsivo)
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: _buildPaymentStatus(),
                      ),
                      const SizedBox(height: 30),

                      // --- CHECKLISTS EM CARDS ---
                      if (project.status == ProjectStatus.notStarted &&
                          project.executionChecklist.isEmpty) ...[
                        Align(
                          alignment: Alignment.center,
                          child: Text("Checklist Inicial",
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              )),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.grey[50],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Checklist de Execução do Projeto",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Salvar checklist do projeto"),
                        ),
                      ] else if (project.executionChecklist.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Checklist de Execução do Projeto",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.grey[50],
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}