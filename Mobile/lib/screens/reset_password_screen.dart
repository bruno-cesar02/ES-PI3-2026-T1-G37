/* Tomás Cubeiro RA: 24023817 */
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/forgot_password_service.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_texto.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController novaSenhaController = TextEditingController();
  final TextEditingController confirmarSenhaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _alterarSenha() async {
    // Pega o email que veio da tela anterior
    final email = ModalRoute.of(context)!.settings.arguments as String;
    final novaSenha = novaSenhaController.text.trim();
    final confirmarSenha = confirmarSenhaController.text.trim();

    if (novaSenha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem('Preencha todos os campos.');
      return;
    }

    if (novaSenha != confirmarSenha) {
      _mostrarMensagem('As senhas não coincidem.');
      return;
    }

    if (novaSenha.length < 6) {
      _mostrarMensagem('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ForgotPasswordService.alterarSenha(
        email: email,
        novaSenha: novaSenha,
      );
      if (!mounted) return;
      _mostrarMensagem('Senha alterada com sucesso!');
      // Volta para a tela inicial
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
    novaSenhaController.dispose();
    confirmarSenhaController.dispose();
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
                            "Redefinir senha",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          CampoTexto(
                            label: "Nova senha",
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
                          _isLoading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF1E90FF))
                              : BotaoPrimario(
                                  texto: "Confirmar",
                                  isPrimary: true,
                                  onPressed: _alterarSenha,
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