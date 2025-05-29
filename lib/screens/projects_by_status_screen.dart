import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          ? Center(child: Text("Nenhum projeto encontrado.", style: Theme.of(context).textTheme.bodySmall))
          : ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: projects.length,
        itemBuilder: (context, idx) => GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/project-detail',
            arguments: projects[idx],
          ),
          child: ProjectCard(project: projects[idx]),
        ),
      ),
    );
  }
}