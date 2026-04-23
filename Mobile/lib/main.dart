import 'package:flutter/material.dart';
import 'screens/tela_inicial_screen.dart';

// ─────────────────────────────────────────────
// Ponto de entrada do app — não mude essa linha
// ─────────────────────────────────────────────
void main() {
  runApp(const MesclaInvestApp());
}

class MesclaInvestApp extends StatelessWidget {
  const MesclaInvestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MesclaInvest',
      debugShowCheckedModeBanner: false, // remove o banner "debug" no canto

      // ── Tema global do app ──────────────────────────────────────────
      // Centraliza as cores para você não precisar repetir em toda tela.
      // Quando o design mudar, você muda só aqui.
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E90FF),   // azul dos botões primários
          surface: Color(0xFF000759),   // azul escuro do fundo
        ),
        fontFamily: 'SF Pro', // troque por 'Inter' se não tiver SF Pro
      ),

      // ── Tela inicial ────────────────────────────────────────────────
      // É aqui que você define qual tela aparece primeiro.
      home: const TelaInicialScreen(),

      // ── Rotas nomeadas ──────────────────────────────────────────────
      // Funciona como um mapa de endereços do app.
      // Para navegar: Navigator.pushNamed(context, '/cadastro')
      //
      // ADICIONE AQUI cada nova tela que você criar:
      routes: {
        '/cadastro': (context) => const Placeholder(), // → troque por CadastroScreen()
        '/login':    (context) => const Placeholder(), // → troque por LoginScreen()
        // '/esqueceu-senha': (context) => const EsqueceuSenhaScreen(),
        // '/dashboard':      (context) => const DashboardScreen(),
      },
    );
  }
}