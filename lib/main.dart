import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/project_provider.dart';
import 'providers/client_provider.dart';
import 'providers/service_type_provider.dart';
import 'app.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => ServiceTypeProvider()),
      ],
      child: const RootApp(),
    ),
  );
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mostra uma tela de loading enquanto detecta o login
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        // Se não está logado, mostra tela de login
        if (snapshot.data == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
            },
          );
        }
        // Se está logado, mostra o app principal
        return const MyApp();
      },
    );
  }
}
