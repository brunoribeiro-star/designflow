import 'package:flutter/material.dart';
import '../models/project.dart';
import 'status_dot.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            StatusDot(status: project.deadlineStatus),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("Cliente: ${project.client.name}"),
                  Text("Entrega: ${project.deadline.day}/${project.deadline.month}/${project.deadline.year}"),
                  Text(
                    project.status == ProjectStatus.notStarted
                        ? "Não iniciado"
                        : project.status == ProjectStatus.inProgress
                        ? "Em andamento"
                        : "Finalizado",
                    style: TextStyle(
                        color: project.status == ProjectStatus.finished
                            ? Colors.green
                            : (project.status == ProjectStatus.inProgress
                            ? Colors.orange
                            : Colors.grey[700])),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}