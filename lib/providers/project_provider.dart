import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project.dart';
import '../models/client.dart';
import '../models/service_type.dart';

class ProjectProvider with ChangeNotifier {
  final List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  List<Project> get notStartedProjects =>
      _projects.where((p) => p.status == ProjectStatus.notStarted).toList();
  List<Project> get inProgressProjects =>
      _projects.where((p) => p.status == ProjectStatus.inProgress).toList();
  List<Project> get finishedProjects =>
      _projects.where((p) => p.status == ProjectStatus.finished).toList();

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> loadProjects() async {
    if (_userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .get();

    _projects.clear();
    for (var doc in snapshot.docs) {
      _projects.add(Project.fromFirestore(doc));
    }
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    if (_userId == null) return;

    final ref = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .add(project.toFirestore());

    project.id = ref.id;
    _projects.insert(0, project);
    notifyListeners();
  }

  Future<void> updateProject(Project original, Project updated) async {
    if (_userId == null || original.id == null) return;

    updated.id = original.id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .doc(original.id)
        .set(updated.toFirestore());

    final index = _projects.indexWhere((p) => p.id == original.id);
    if (index != -1) {
      _projects[index] = updated;
      notifyListeners();
    }
  }

  Future<void> removeProject(Project project) async {
    if (_userId == null || project.id == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .doc(project.id)
        .delete();

    _projects.removeWhere((p) => p.id == project.id);
    notifyListeners();
  }

  Future<void> toggleChecklistItem(Project project, ChecklistItem item) async {
    final pIndex = _projects.indexWhere((p) => p.id == project.id);
    if (pIndex != -1) {
      final cIndex =
      _projects[pIndex].checklist.indexWhere((i) => i.title == item.title);
      if (cIndex != -1) {
        _projects[pIndex].checklist[cIndex].isDone = item.isDone;
        await updateProject(_projects[pIndex], _projects[pIndex]);
      }
    }
  }

  Future<void> toggleExecutionChecklistItem(Project project, ChecklistItem item) async {
    final pIndex = _projects.indexWhere((p) => p.id == project.id);
    if (pIndex != -1) {
      final cIndex = _projects[pIndex]
          .executionChecklist
          .indexWhere((i) => i.title == item.title);
      if (cIndex != -1) {
        _projects[pIndex].executionChecklist[cIndex].isDone = item.isDone;
        await updateProject(_projects[pIndex], _projects[pIndex]);
      }
    }
  }

  Future<void> setExecutionChecklist(Project project, List<ChecklistItem> checklist) async {
    final pIndex = _projects.indexWhere((p) => p.id == project.id);
    if (pIndex != -1) {
      _projects[pIndex].executionChecklist = List.from(checklist);
      await updateProject(_projects[pIndex], _projects[pIndex]);
    }
  }

  Future<void> changeStatus(Project project, ProjectStatus status) async {
    final pIndex = _projects.indexWhere((p) => p.id == project.id);
    if (pIndex != -1) {
      _projects[pIndex].status = status;
      await updateProject(_projects[pIndex], _projects[pIndex]);
    }
  }

  Future<void> updatePaymentStatus(Project project, bool isPaid) async {
    final pIndex = _projects.indexWhere((p) => p.id == project.id);
    if (pIndex != -1) {
      _projects[pIndex].isPaid = isPaid;
      await updateProject(_projects[pIndex], _projects[pIndex]);
    }
  }

  Future<void> reload() async {
    await loadProjects();
  }

  void clearProjects() {
    _projects.clear();
    notifyListeners();
  }
}