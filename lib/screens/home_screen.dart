import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/project_provider.dart';
import '../models/project.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _menuOpen = false;

  void _toggleMenu() {
    setState(() => _menuOpen = !_menuOpen);
  }

  void _closeMenu() {
    if (_menuOpen) setState(() => _menuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);
    final theme = Theme.of(context);

    // Contagem de cada status
    final int notStarted = projectProvider.projects
        .where((p) => p.status == ProjectStatus.notStarted)
        .length;
    final int inProgress = projectProvider.projects
        .where((p) => p.status == ProjectStatus.inProgress)
        .length;
    final int finished = projectProvider.projects
        .where((p) => p.status == ProjectStatus.finished)
        .length;

    return GestureDetector(
      onTap: _closeMenu,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Conteúdo principal
            Column(
              children: [
                AppBar(
                  title: const Text('DesignFlow'),
                  elevation: 0,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF5E60CE),
                  leading: IconButton(
                    icon: Icon(
                      _menuOpen ? Icons.close : Icons.menu,
                      color: const Color(0xFFF9F9FB),
                    ),
                    onPressed: _toggleMenu,
                    tooltip: _menuOpen ? "Fechar menu" : "Menu",
                  ),
                  actions: const [],
                ),
                // O resto do conteúdo da tela
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Mensagem de boas-vindas
                          Text(
                            "Bem-vindo ao DesignFlow 👋",
                            style: theme.textTheme.bodyLarge!.copyWith(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Visualize e organize seus projetos por etapa.\nEscolha uma categoria abaixo:",
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),

                          // Card: Projetos a iniciar
                          _StatusCard(
                            icon: Icons.access_time_rounded,
                            label: "A Iniciar",
                            count: notStarted,
                            color: Colors.orange[600]!,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/projects-by-status',
                                arguments: {
                                  "status": ProjectStatus.notStarted,
                                  "title": "Projetos a Iniciar"
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 18),

                          // Card: Em andamento
                          _StatusCard(
                            icon: Icons.play_arrow_rounded,
                            label: "Em Andamento",
                            count: inProgress,
                            color: Colors.blue[700]!,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/projects-by-status',
                                arguments: {
                                  "status": ProjectStatus.inProgress,
                                  "title": "Projetos em Andamento"
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 18),

                          // Card: Finalizados
                          _StatusCard(
                            icon: Icons.check_circle_rounded,
                            label: "Finalizados",
                            count: finished,
                            color: Colors.green[600]!,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/projects-by-status',
                                arguments: {
                                  "status": ProjectStatus.finished,
                                  "title": "Projetos Finalizados"
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 38),

                          // Botão de adicionar novo projeto (CTA destacado)
                          SizedBox(
                            width: 220,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add, color: Colors.white,),
                              label: const Text("Novo Projeto"),
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
                              onPressed: () => Navigator.pushNamed(context, '/add-project'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Overlay do Menu Hamburguer
            if (_menuOpen)
              Positioned(
                top: kToolbarHeight, // logo abaixo da AppBar
                left: 0,
                right: 0,
                child: Material(
                  color: Colors.white,
                  elevation: 3,
                  child: Column(
                    children: [
                      _MenuItemVertical(
                        icon: Icons.people_alt_rounded,
                        label: "Gerenciar Clientes",
                        onTap: () {
                          _closeMenu();
                          Navigator.pushNamed(context, '/clients');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      _MenuItemVertical(
                        icon: Icons.design_services_rounded,
                        label: "Tipos de Serviço",
                        onTap: () {
                          _closeMenu();
                          Navigator.pushNamed(context, '/service-types');
                        },
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                      _MenuItemVertical(
                        icon: Icons.logout_rounded,
                        label: "Sair",
                        color: const Color(0xFFEA6C66),
                        onTap: () async {
                          _closeMenu();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          await FirebaseAuth.instance.signOut();
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemVertical extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItemVertical({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xFF5E60CE)),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: color ?? const Color(0xFF5E60CE),
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Card customizado para o status do projeto
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _StatusCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.13),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: const Color(0xFF1C1C1C),
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
            Text(
              "$count",
              style: theme.textTheme.bodyMedium!.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}