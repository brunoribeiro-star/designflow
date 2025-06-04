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

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final projects = projectProvider.projects
        .where((p) => p.status == status)
        .toList();

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
                          title: const Text('Excluir projeto'),
                          content: Text(
                              'Tem certeza que deseja excluir o projeto "${project.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Excluir'),
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