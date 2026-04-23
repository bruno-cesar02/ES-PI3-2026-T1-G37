import 'package:flutter/material.dart';
import '../widgets/botao_primario.dart';

/// Tela Inicial do MesclaInvest.
///
/// Navegação:
/// - Botão "Cadastro"        → rota '/cadastro'
/// - Botão "Login no Mescla" → rota '/login'
class TelaInicialScreen extends StatelessWidget {
  const TelaInicialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camada 1: Gradiente de fundo ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF000759),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),

          // ── Camada 2: Efeito de luz azul ──────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_blur.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ── Camada 3: Conteúdo principal ──────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 39),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──────────────────────────────────────────────
                  Image.asset(
                    'assets/images/logo_mescla.png',
                    width: 234,
                    errorBuilder: (_, __, ___) => const Text(
                      'mescla\ninvest',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Distância proporcional à altura da tela entre logo e botões
                  SizedBox(height: altura * 0.30),

                  // ── Botão primário: Cadastro ───────────────────────────
                  BotaoPrimario(
                    texto: 'Cadastro',
                    isPrimary: true,
                    onPressed: () {
                      Navigator.pushNamed(context, '/cadastro');
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Botão secundário: Login ────────────────────────────
                  BotaoPrimario(
                    texto: 'Login no MesclaInvest',
                    isPrimary: false,
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}