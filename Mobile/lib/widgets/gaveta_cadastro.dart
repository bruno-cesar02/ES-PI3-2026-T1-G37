import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'package:mobile/services/AuthService.dart';
import 'gaveta_login.dart'; // Para poder trocar de tela

class GavetaCadastro extends StatefulWidget {
  const GavetaCadastro({super.key});

  @override
  State<GavetaCadastro> createState() => _GavetaCadastroState();
}

class _GavetaCadastroState extends State<GavetaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _carregando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _enviarCadastro() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _cpfController.text.isEmpty || _celularController.text.isEmpty || _senhaController.text.isEmpty) {
      _erro('Preencha todos os campos.');
      return;
    }
    if (_senhaController.text != _confirmarSenhaController.text) {
      _erro('As senhas não coincidem.');
      return;
    }

    setState(() => _carregando = true);
    try {
      await AuthService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        celular: _celularController.text.trim(),
        senha: _senhaController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro realizado! Faça login.')));
      }
    } catch (e) {
      _erro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _erro(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A4A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Atenção', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(msg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1E90FF), fontSize: 16)),
          ),
        ],
      ),
    );
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
                  const Text('Cadastro', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      children: [
                        TextSpan(text: 'Crie sua conta e comece investir\nem startups com o '),
                        TextSpan(text: 'MesclaInvest', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  CampoTexto(label: 'Nome Completo', controller: _nomeController),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'CPF', controller: _cpfController, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'Celular', controller: _celularController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'Senha', controller: _senhaController, obscureText: true),
                  const SizedBox(height: 12),
                  CampoTexto(label: 'Confirmar senha', controller: _confirmarSenhaController, obscureText: true),
                  const SizedBox(height: 28),
                  _carregando
                      ? const CircularProgressIndicator(color: Color(0xFF1E90FF))
                      : BotaoPrimario(texto: 'Enviar', isPrimary: true, onPressed: _enviarCadastro),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                            builder: (_) => const GavetaLogin(),
                          );
                        }
                      });
                    },
                    child: const Text('Já tem conta? Faça login', style: TextStyle(color: Colors.white70)),
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