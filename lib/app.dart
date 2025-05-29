import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_project_screen.dart';
import 'screens/project_detail_screen.dart';
import 'screens/clients_screen.dart';
import 'screens/service_types_screen.dart';
import 'screens/projects_by_status_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Organizer Designers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
        primaryColor: const Color(0xFF5E60CE),
        colorScheme: ColorScheme(
          primary: const Color(0xFF5E60CE),
          primaryContainer: const Color(0xFF5E60CE),
          secondary: const Color(0xFF5E60CE),
          secondaryContainer: const Color(0xFF5E60CE),
          background: const Color(0xFFF9F9FB),
          surface: Colors.white,
          error: Colors.red,
          onPrimary: const Color(0xFFF9F9FB),
          onSecondary: const Color(0xFFF9F9FB),
          onSurface: const Color(0xFF1C1C1C),
          onBackground: const Color(0xFF1C1C1C),
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5E60CE),
          foregroundColor: Color(0xFFF9F9FB),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Color(0xFFF9F9FB),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            color: Color(0xFF1C1C1C),
            fontWeight: FontWeight.w600, // semi-bold
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFF1C1C1C),
            fontWeight: FontWeight.w600, // semi-bold
          ),
          bodySmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6E6E73),
            fontWeight: FontWeight.w400, // regular
          ),
          labelLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            color: Color(0xFFF9F9FB),
            fontWeight: FontWeight.w600, // botões semi-bold
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF5E60CE), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          hintStyle: TextStyle(
            color: Color(0xFF6E6E73),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E60CE),
            foregroundColor: const Color(0xFFF9F9FB),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5E60CE),
          foregroundColor: Color(0xFFF9F9FB),
        ),
        dividerColor: const Color(0xFFE0E0E0),
        cardColor: Colors.white,
      ),
      // <<<<<< TUDO ABAIXO MUDA >>>>>>
      home: const AuthGate(),
      routes: {
        '/add-project': (context) => const AddProjectScreen(),
        '/project-detail': (context) => const ProjectDetailScreen(),
        '/clients': (context) => const ClientsScreen(),
        '/service-types': (context) => const ServiceTypesScreen(),
        '/projects-by-status': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProjectsByStatusScreen(
            status: args['status'],
            title: args['title'],
          );
        },
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostra loading durante inicialização
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Logado: tela principal
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Não logado: tela de login
        return const LoginScreen();
      },
    );
  }
}