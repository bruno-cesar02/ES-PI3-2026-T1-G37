import 'package:flutter/material.dart';
import 'package:mobile/services/logar_service.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'gaveta_cadastro.dart'; // Para poder trocar de tela
import 'notificacao.dart';

class GavetaLogin extends StatefulWidget {
  const GavetaLogin({super.key});

  @override
  State<GavetaLogin> createState() => _GavetaLoginState();
}

class _GavetaLoginState extends State<GavetaLogin> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _enviarLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      Notificacao.erro(context, 'Preencha e-mail e senha.');
      return;
    }
    setState(() {
      _carregando = true;
    });

    try {
      final sucesso = await LogarService.logar(
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      if (sucesso) {
        if (mounted) {
          Notificacao.sucesso(context, 'Login realizado com sucesso!');
          Navigator.pop(context);
          //Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        Notificacao.erro(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
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
            width: 60, height: 5,
            decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottomInset + 16),
              child: Column(
                children: [
                  const Text('Login', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      children: [
                        TextSpan(text: 'Bem-vindo de volta ao '),
                        TextSpan(text: 'MesclaInvest', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  CampoTexto(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'Senha', controller: _senhaController, obscureText: true),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          Notificacao.info(context, 'A recuperacao de senha será implementada em breve.');
                        },
                      // 👇 isso está faltando
                      child: const Text(
                        'esqueceu a senha?',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(height: 28),
                  _carregando
                      ? const CircularProgressIndicator(color: Color(0xFF1E90FF))
                      : BotaoPrimario(texto: 'Entrar', isPrimary: true, onPressed: _enviarLogin),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (_) => const GavetaCadastro(),
                          );
                        }
                      });
                    },
                    child: const Text('Não tem conta? Cadastre-se', style: TextStyle(color: Colors.white70)),
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