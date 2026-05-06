/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'notificacao.dart';
import 'package:mobile/services/AuthService.dart';
import 'gaveta_login.dart';

class GavetaCadastro extends StatefulWidget {
  const GavetaCadastro({super.key});

  @override
  State<GavetaCadastro> createState() => _GavetaCadastroState();
}

class _GavetaCadastroState extends State<GavetaCadastro> {
  final _nomeController           = TextEditingController();
  final _emailController          = TextEditingController();
  final _cpfController            = TextEditingController();
  final _celularController        = TextEditingController();
  final _senhaController          = TextEditingController();
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

  // ── Validação alinhada com o backend ──────────────────────────
  // O Firebase Auth exige mínimo 6 chars, mas a gente pede 8
  // para segurança. Os outros requisitos são validados aqui no Flutter
  // antes de chamar o backend (evita chamadas desnecessárias).
  String? _validarSenha(String senha) {
    if (senha.length < 8)                                    return 'Mínimo 8 caracteres.';
    if (!senha.contains(RegExp(r'[A-Z]')))                   return 'Adicione uma letra maiúscula.';
    if (!senha.contains(RegExp(r'[a-z]')))                   return 'Adicione uma letra minúscula.';
    if (!senha.contains(RegExp(r'[0-9]')))                   return 'Adicione um número.';
    if (!senha.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) return 'Adicione um símbolo (!@#\$%&*).';
    return null; // null = senha válida
  }

  Future<void> _enviarCadastro() async {
    // Campos vazios
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _celularController.text.isEmpty ||
        _senhaController.text.isEmpty ||
        _confirmarSenhaController.text.isEmpty) {
      Notificacao.erro(context, 'Preencha todos os campos antes de continuar.');
      return;
    }

    // Requisitos da senha
    final erroSenha = _validarSenha(_senhaController.text);
    if (erroSenha != null) {
      Notificacao.erro(context, erroSenha);
      return;
    }

    // Senhas coincidem
    if (_senhaController.text != _confirmarSenhaController.text) {
      Notificacao.erro(context, 'As senhas não coincidem. Verifique e tente novamente.');
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
        Notificacao.sucesso(context, 'Conta criada com sucesso! Faça login para continuar.');
      }
    } catch (e) {
      Notificacao.erro(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
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
                  const Text(
                    'Cadastro',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                      children: [
                        TextSpan(text: 'Crie sua conta e comece investir\nem startups com o '),
                        TextSpan(
                          text: 'MesclaInvest',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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

                  // Campo de senha COM olho + requisitos
                  CampoSenha(
                    label: 'Senha',
                    controller: _senhaController,
                    mostrarRequisitos: true, // só o campo principal mostra os requisitos
                  ),
                  const SizedBox(height: 12),

                  // Confirmar senha COM olho, SEM requisitos (não precisa repetir)
                  CampoSenha(
                    label: 'Confirmar senha',
                    controller: _confirmarSenhaController,
                    mostrarRequisitos: false,
                  ),
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
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const GavetaLogin(),
                          );
                        }
                      });
                    },
                    child: const Text(
                      'Já tem conta? Faça login',
                      style: TextStyle(color: Colors.white70),
                    ),
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