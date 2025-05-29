import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../providers/project_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Limpa/carrega os projetos do novo usuário cadastrado
      await Provider.of<ProjectProvider>(context, listen: false).loadProjects();
      Navigator.pop(context); // Volta pro login (AuthGate vai redirecionar)
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.code == 'email-already-in-use'
            ? "Este e-mail já está em uso"
            : "Erro ao criar conta";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5E60CE);
    const bgColor = Color(0xFFF9F9FB);
    const borderColor = Color(0xFFE0E0E0);
    const textMain = Color(0xFF1C1C1C);
    const textSecondary = Color(0xFF6E6E73);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.04),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Criar nova conta",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                      color: textMain,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(fontFamily: 'Inter', color: textMain),
                    decoration: InputDecoration(
                      labelText: "Nome completo",
                      prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      labelStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? "Digite seu nome" : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(fontFamily: 'Inter', color: textMain),
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      prefixIcon: const Icon(Icons.email_outlined, color: primaryColor),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      labelStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) =>
                    value == null || value.isEmpty ? "Digite o e-mail" : null,
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(fontFamily: 'Inter', color: textMain),
                    decoration: InputDecoration(
                      labelText: "Senha",
                      prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                      filled: true,
                      fillColor: bgColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      labelStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                      hintStyle: const TextStyle(
                        color: textSecondary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6
                        ? "Senha deve ter no mínimo 6 caracteres"
                        : null,
                  ),
                  const SizedBox(height: 18),

                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                        if (_formKey.currentState?.validate() == true) {
                          _register();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: bgColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                          fontSize: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Criar Conta"),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Já possui conta?",
                        style: TextStyle(
                          color: textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Entrar",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}