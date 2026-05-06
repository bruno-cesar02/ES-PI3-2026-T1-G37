/* Tomás Cubeiro RA: 24023817 */ 
import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/botao_primario.dart';
import '../widgets/campo_texto.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;
    final TextEditingController emailController = TextEditingController();

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
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset(
                  'assets/images/logo_mescla.png',
                  width: 234,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error, color: Colors.white),
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
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Recuperar senha",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          CampoTexto(
                            label: "Email",
                            controller: emailController,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          BotaoPrimario(
                            texto: "Enviar",
                            isPrimary: true,
                            onPressed: () {
                              print("Email: ${emailController.text}");
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          BotaoPrimario(
                            texto: "Voltar",
                            isPrimary: false,
                            onPressed: () => Navigator.pop(context),
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