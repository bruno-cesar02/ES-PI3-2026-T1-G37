import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/botao_primario.dart';
import '../widgets/campo_texto.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController novaSenhaController = TextEditingController();
    final TextEditingController confirmarSenhaController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000759), Color(0xFF000000)],
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_blur.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/logo_mescla.png',
                  width: 234,
                ),
                const Spacer(), 
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 39, vertical: 32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60, height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Recuperar senha",
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 32),
                          
                          CampoTexto(
                            label: "Insira nova senha",
                            controller: novaSenhaController,
                            obscureText: true,
                          ),
                          
                          const SizedBox(height: 16),

                          CampoTexto(
                            label: "Confirmar senha",
                            controller: confirmarSenhaController,
                            obscureText: true,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          BotaoPrimario(
                            texto: "Recuperar",
                            isPrimary: true,
                            onPressed: () {
                              print("Nova senha definida!");
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}