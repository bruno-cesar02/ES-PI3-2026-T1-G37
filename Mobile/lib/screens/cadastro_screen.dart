/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'package:flutter/material.dart';
import 'package:mobile/services/AuthService.dart';
import '../widgets/campo_texto.dart';
import '../widgets/botao_primario.dart';


/// Tela de Cadastro do MesclaInvest.
///
/// Analogia: pense nessa tela como uma gaveta numa mesa.
/// A gaveta começa fechada (só aparece o fundo e o logo).
/// Quando o Flutter abre essa tela, a gaveta desliza pra cima
/// mostrando o formulário — isso é a animação.
///
/// Fluxo de dados:
/// Usuário digita → aperta "Enviar" → AuthService manda pro Node.js
/// → Node salva no Firebase → app navega pro dashboard.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen>
    with SingleTickerProviderStateMixin {
  // ── Animação ────────────────────────────────────────────────────
  // Pense no AnimationController como o trilho da gaveta.
  // Ele controla QUANTO a gaveta já abriu (de 0% a 100%).
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  // ── Controladores dos campos ─────────────────────────────────────
  // Cada um "ouve" o que o usuário digita em cada campo.
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _celularController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // Estado do botão de envio
  bool _carregando = false;

  @override
  void initState() {
    super.initState();

    // Configura a animação: duração de 500ms, curva suave
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // A gaveta começa lá embaixo (Offset(0, 1) = 100% pra baixo)
    // e vai até a posição final (Offset(0, 0) = no lugar certo)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),  // começa fora da tela, embaixo
      end: Offset.zero,            // termina na posição correta
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,       // desacelera no final (mais natural)
    ));

    // Dispara a animação assim que a tela abre
    _controller.forward();
  }

  @override
  void dispose() {
    // Libera memória quando sai da tela
    _controller.dispose();
    _nomeController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _celularController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  // ── Lógica de cadastro ──────────────────────────────────────────
  Future<void> _enviarCadastro() async {
    // Validação básica antes de chamar a API
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _celularController.text.isEmpty ||
        _senhaController.text.isEmpty) {
      _mostrarErro('Preencha todos os campos.');
      return;
    }

    if (_senhaController.text != _confirmarSenhaController.text) {
      _mostrarErro('As senhas não coincidem.');
      return;
    }

    setState(() => _carregando = true);

    try {
      // Chama o AuthService (o "garçom") que manda pro Node.js
      await AuthService.cadastrar(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        celular: _celularController.text.trim(),
        senha: _senhaController.text,
      );

      // Cadastro ok — navega pro login ou dashboard
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _mostrarErro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mostrarErro(String mensagem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A4A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Atenção',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          mensagem,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1E90FF), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camada 1: Gradiente de fundo (igual à tela inicial) ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000759), Color(0xFF000000)],
              ),
            ),
          ),

          // ── Camada 2: Efeito de blur azul ────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_blur.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ── Camada 3: Logo no topo ───────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 32,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/logo_mescla.png',
                width: 180,
                errorBuilder: (_, __, ___) => const Text(
                  'mescla\ninvest',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // ── Camada 4: A "gaveta" que sobe com animação ───────────
          // SlideTransition = o trilho que move a gaveta
          SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // A gaveta ocupa ~80% da altura da tela
                height: MediaQuery.of(context).size.height * 0.80,
                decoration: BoxDecoration(
                  // Cinza-azulado semi-transparente, igual ao Figma
                  color: const Color(0xFFEBEDF1).withOpacity(0.30),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Barrinha de "puxador" no topo da gaveta
                    const SizedBox(height: 12),
                    Container(
                      width: 60,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Conteúdo do formulário dentro da gaveta
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Título
                            const Text(
                              'Cadastro',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Subtítulo com MesclaInvest em negrito
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

                            // ── Campos do formulário ────────────────
                            CampoTexto(label: 'Nome Completo', controller: _nomeController),
                            const SizedBox(height: 12),
                            CampoTexto(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              label: 'CPF',
                              controller: _cpfController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              label: 'Celular',
                              controller: _celularController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              label: 'Senha',
                              controller: _senhaController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 12),
                            CampoTexto(
                              label: 'Confirmar senha',
                              controller: _confirmarSenhaController,
                              obscureText: true,
                            ),
                            const SizedBox(height: 28),

                            // ── Botão Enviar ────────────────────────
                            // Mostra um loading enquanto está cadastrando
                            _carregando
                                ? const CircularProgressIndicator(color: Color(0xFF1E90FF))
                                : BotaoPrimario(
                              texto: 'Enviar',
                              isPrimary: true,
                              onPressed: _enviarCadastro,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}