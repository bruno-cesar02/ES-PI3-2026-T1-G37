/* Bruno César Gonçalves Lima Mota
   RA: 24795502 */

import 'package:flutter/material.dart';
import 'config/firebase_setup.dart'; 
import 'screens/tela_inicial_screen.dart';
import 'screens/forgot_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Chama a configuração do banco de dados 
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

      // ── TEMA GLOBAL DO APP ──────────────────────────────────────────
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E90FF),
          surface: Color(0xFF000759),
        ),
        fontFamily: 'SF Pro',
      ),

      // ── TELA INICIAL ────────────────────────────────────────────────
      home: const TelaInicialScreen(),
      initialRoute: '/esqueceu-senha',

      // ── ROTAS DO APLICATIVO ─────────────────────────────────────────
      
      routes: {
        
      // ── Tela inicial ────────────────────────────────────────────────
      // É aqui que você define qual tela aparece primeiro.
      // home: const TelaInicialScreen(),

      // ── Rotas nomeadas ──────────────────────────────────────────────
      // Funciona como um mapa de endereços do app.
      // Para navegar: Navigator.pushNamed(context, '/cadastro')
      //
      // ADICIONE AQUI cada nova tela que você criar:
        '/cadastro': (context) => const Placeholder(), // → troque por CadastroScreen()
        '/login':    (context) => const Placeholder(), // → troque por LoginScreen()
        '/esqueceu-senha': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}