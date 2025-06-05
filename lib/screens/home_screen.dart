import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/project_provider.dart';
import '../models/project.dart';
import '../services/quote_service.dart'; // <<< IMPORTANTE!

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

  // Função para exibir pop-up com frase inspiradora
  Future<void> _showInspirationalQuote() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final quote = await QuoteService.fetchRandomQuote();
      Navigator.of(context, rootNavigator: true).pop(); // Fecha o loading

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Dose de Inspiração ✨'),
          content: Text('"${quote.content}"\n\n— ${quote.author}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Erro: $e"); // <-- ESSA LINHA MOSTRA O ERRO NO LOG
      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Não foi possível obter uma frase agora. Tente novamente depois.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    }
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

    return Scaffold(
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
                    Icons.menu,
                    color: const Color(0xFFF9F9FB),
                  ),
                  onPressed: _toggleMenu,
                  tooltip: "Menu",
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
                        const SizedBox(height: 18),

                        // ============= BOTÃO "DOSE DE INSPIRAÇÃO" =============
                        SizedBox(
                          width: 220,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF5E60CE)),
                            label: const Text(
                              "Dose de Inspiração",
                              style: TextStyle(color: Color(0xFF5E60CE)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF5E60CE), width: 2),
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
                            onPressed: _showInspirationalQuote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Overlay do Menu Hamburguer - Cobre toda a tela com animação e centralizado
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 230),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: _menuOpen
                ? GestureDetector(
              onTap: _closeMenu,
              child: Container(
                key: const ValueKey('menu'),
                color: Colors.white.withOpacity(0.98),
                width: double.infinity,
                height: double.infinity,
                child: SafeArea(
                  child: Stack(
                    children: [
                      // Botão fechar
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF5E60CE), size: 32),
                          tooltip: "Fechar menu",
                          onPressed: _closeMenu,
                        ),
                      ),
                      // Menu centralizado
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MenuItemVertical(
                              icon: Icons.people_alt_rounded,
                              label: "Gerenciar Clientes",
                              onTap: () {
                                _closeMenu();
                                Navigator.pushNamed(context, '/clients');
                              },
                              centerContent: true,
                            ),
                            const SizedBox(height: 12),
                            _MenuItemVertical(
                              icon: Icons.design_services_rounded,
                              label: "Tipos de Serviço",
                              onTap: () {
                                _closeMenu();
                                Navigator.pushNamed(context, '/service-types');
                              },
                              centerContent: true,
                            ),
                            const SizedBox(height: 12),
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
                              centerContent: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _MenuItemVertical extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool centerContent;

  const _MenuItemVertical({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        minimumSize: const Size(180, 48),
        alignment: Alignment.center,
        foregroundColor: color ?? const Color(0xFF5E60CE),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? const Color(0xFF5E60CE), size: 26),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: color ?? const Color(0xFF5E60CE),
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
              fontSize: 18,
            ),
          ),
        ],
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