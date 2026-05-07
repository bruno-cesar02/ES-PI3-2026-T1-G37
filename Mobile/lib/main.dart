/* Bruno César Gonçalves Lima Mota
   RA: 24795502 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'config/firebase_setup.dart';
import 'screens/tela_inicial_screen.dart';
import 'screens/tela_logada_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseSetup.inicializar();
  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E90FF),
          surface: Color(0xFF000759),
        ),
        fontFamily: 'SF Pro',
      ),

      // ── Verifica se o usuário já está logado ──────────────────────────────
      // Se sim → vai direto para o catálogo
      // Se não → vai para a tela inicial (login/cadastro)
      home: FirebaseAuth.instance.currentUser != null
          ? const TelaLogadaScreen()
          : const TelaInicialScreen(),

      routes: {
        '/esqueceu-senha': (context) => const ForgotPasswordScreen(),
        '/redefinir-senha': (context) => const ResetPasswordScreen(),
      },
    );
  }
}