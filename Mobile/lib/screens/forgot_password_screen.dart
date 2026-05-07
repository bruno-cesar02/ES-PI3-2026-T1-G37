/* Tomás Cubeiro RA: 24023817 */

import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/forgot_password_service.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_texto.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verificarEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _mostrarMensagem('Por favor, informe seu e-mail.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ForgotPasswordService.verificarEmail(email: email);
      if (!mounted) return;
      // Passa o email para a próxima tela
      Navigator.pushNamed(context, '/redefinir-senha', arguments: email);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFF1E90FF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.error, color: Colors.white),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 39, vertical: 32),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
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
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF1E90FF))
                              : BotaoPrimario(
                                  texto: "Enviar",
                                  isPrimary: true,
                                  onPressed: _verificarEmail,
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