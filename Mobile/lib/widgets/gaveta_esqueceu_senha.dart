
import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import '../services/forgot_password_service.dart';

class GavetaEsqueceuSenha extends StatefulWidget {
  const GavetaEsqueceuSenha({super.key});

  @override
  State<GavetaEsqueceuSenha> createState() => _GavetaEsqueceuSenhaState();
}

class _GavetaEsqueceuSenhaState extends State<GavetaEsqueceuSenha> {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailEnviado = false;

  Future<void> _enviarEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _mostrarMensagem('Por favor, informe seu e-mail.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ForgotPasswordService.enviarEmailRecuperacao(email: email);
      if (!mounted) return;
      setState(() => _emailEnviado = true);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensagem(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82 + bottomInset,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A4A).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottomInset + 16),
              child: Column(
                children: [
                  if (_emailEnviado) ...[
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.mark_email_read_outlined,
                      color: Colors.white,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'E-mail enviado!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Verifique sua caixa de entrada e siga as instruções para redefinir sua senha.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    BotaoPrimario(
                      texto: 'Fechar',
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ] else ...[
                    const Text(
                      'Recuperar senha',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    CampoTexto(
                      label: 'Email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF1E90FF))
                        : BotaoPrimario(
                            texto: 'Enviar',
                            isPrimary: true,
                            onPressed: _enviarEmail,
                          ),
                    const SizedBox(height: 16),
                    BotaoPrimario(
                      texto: 'Voltar',
                      isPrimary: false,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}