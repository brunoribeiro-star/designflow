import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/project_card.dart';

class ProjectsByStatusScreen extends StatelessWidget {
  final ProjectStatus status;
  final String title;

  const ProjectsByStatusScreen({
    Key? key,
    required this.status,
    required this.title,
  }) : super(key: key);
  ButtonStyle get _primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF5E60CE),
    foregroundColor: Colors.white,
    minimumSize: const Size(110, 42),
    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  ButtonStyle get _cancelButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF5E60CE),
    side: const BorderSide(color: Color(0x405E60CE), width: 2),
    minimumSize: const Size(110, 42),
    textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects =
    projectProvider.projects.where((p) => p.status == status).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: projects.isEmpty
          ? Center(
        child: Text(
          "Nenhum projeto encontrado.",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: projects.length,
        itemBuilder: (context, idx) {
          final project = projects[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Slidable(
              key: ValueKey(project.hashCode),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.14,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          title: const Center(
                            child: Text(
                              'Excluir projeto',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: Text(
                            'Tem certeza que deseja excluir o projeto "${project.name}"?',
                            textAlign: TextAlign.center,
                          ),
                          actionsPadding: const EdgeInsets.only(
                              bottom: 12, left: 16, right: 16),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: _primaryButtonStyle,
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Excluir'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: OutlinedButton(
                                    style: _cancelButtonStyle,
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        projectProvider.removeProject(project);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Projeto excluído!')),
                        );
                      }
                    },
                    backgroundColor: Colors.transparent,
                    // Remove padding
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA6C66),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Color(0xFFF9F9FB),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.14,
                children: [
                  CustomSlidableAction(
                    onPressed: (_) {
                      Navigator.pushNamed(
                        context,
                        '/edit-project',
                        arguments: project,
                      );
                    },
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5E60CE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Color(0xFFF9F9FB),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/project-detail',
                  arguments: project,
                ),
                child: ProjectCard(project: project),
              ),
            ),
          );
        },
      ),
    );
  }
}
