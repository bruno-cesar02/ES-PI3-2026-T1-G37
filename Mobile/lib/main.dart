/* Bruno César Gonçalves Lima Mota
   RA: 24795502 */

import 'package:flutter/material.dart';
import 'config/firebase_setup.dart'; // Importa a configuração separada
import 'screens/tela_inicial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Chama a configuração do banco de dados (que agora está em outro arquivo) ──
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

      // ── ROTAS DO APLICATIVO ─────────────────────────────────────────
      // É aqui que você vai registrar as próximas telas inteiras do app!
      routes: {
        // Quando você criar a tela de Dashboard, por exemplo, é só descomentar:
        // '/dashboard': (context) => const DashboardScreen(),

        // E quando criar a tela de Perfil do Investidor/Startup:
        // '/perfil': (context) => const PerfilScreen(),
      },
    );
  }
}