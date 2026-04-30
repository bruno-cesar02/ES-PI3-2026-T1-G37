/* Bruno César Gonçalves Lima Mota
   RA: 24795502 */

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
        fontFamily: 'SF Pro', // troque por 'Inter' s e não tiver SF Pro
      ),

      // ── Tela inicial ────────────────────────────────────────────────
      // É aqui que você define qual tela aparece primeiro.
      home: const TelaInicialScreen(),

      // ── Rotas nomeadas ──────────────────────────────────────────────
      // Como Cadastro e Login agora são "Gavetas" (BottomSheets) que abrem
      // por cima da Tela Inicial, eles não precisam de rotas aqui.
      //
      // ADICIONE AQUI apenas Telas Inteiras novas:
      routes: {
        // Exemplo: Quando o seu amigo terminar o login, ele vai mandar o
        // usuário para o Dashboard, aí vocês adicionam essa rota aqui:
        // '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}