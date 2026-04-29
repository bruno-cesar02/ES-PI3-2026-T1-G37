/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import 'package:flutter/material.dart';
import '../widgets/botao_primario.dart';
import '../widgets/campo_texto.dart';
import 'package:mobile/services/AuthService.dart';

// Mudamos de StatelessWidget para StatefulWidget
// Analogia: antes era uma foto (estática), agora é um vídeo (reage a eventos)
class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  State<TelaInicialScreen> createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  // Essa variável é a "luzinha" — true = botões visíveis, false = botões escondidos
  bool _mostrarBotoes = true;

  void _abrirGaveta(String tipo) async {
    // 1. Apaga a luzinha → botões somem com animação suave
    setState(() => _mostrarBotoes = false);

    // 2. Abre a gaveta e AGUARDA ela fechar
    // O "await" aqui é como segurar uma porta aberta:
    // o código só continua depois que o usuário fechar a gaveta
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GavetaFormulario(tipo: tipo),
    );

    // 3. Gaveta fechou → acende a luzinha de volta → botões reaparecem
    if (mounted) {
      setState(() => _mostrarBotoes = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final altura = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Gradiente de fundo ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000759), Color(0xFF000000)],
              ),
            ),
          ),

          // ── Efeito de luz azul ──────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_blur.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.6),
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

          // ── Conteúdo principal ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 39),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo — sempre visível
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

                  SizedBox(height: altura * 0.18),

                  // AnimatedOpacity = fade suave (como uma lâmpada dimerizando)
                  // Quando _mostrarBotoes = false → opacity vai pra 0 (invisível)
                  // Quando _mostrarBotoes = true  → opacity vai pra 1 (visível)
                  AnimatedOpacity(
                    opacity: _mostrarBotoes ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),

                    // IgnorePointer evita que o usuário clique nos botões
                    // invisíveis enquanto a gaveta está aberta
                    child: IgnorePointer(
                      ignoring: !_mostrarBotoes,
                      child: Column(
                        children: [
                          BotaoPrimario(
                            texto: 'Cadastro',
                            isPrimary: true,
                            onPressed: () => _abrirGaveta('cadastro'),
                          ),
                          const SizedBox(height: 16),
                          BotaoPrimario(
                            texto: 'Login no MesclaInvest',
                            isPrimary: false,
                            onPressed: () => _abrirGaveta('login'),
                          ),
                        ],
                      ),
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


// ════════════════════════════════════════════════════════════════
// A GAVETA
// ════════════════════════════════════════════════════════════════
class _GavetaFormulario extends StatefulWidget {
  final String tipo;
  const _GavetaFormulario({required this.tipo});

  @override
  State<_GavetaFormulario> createState() => _GavetaFormularioState();
}

class _GavetaFormularioState extends State<_GavetaFormulario> {
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

  Future<void> _enviarCadastro() async {
    if (_nomeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _cpfController.text.isEmpty ||
        _celularController.text.isEmpty ||
        _senhaController.text.isEmpty) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado! Faça login.')),
        );
      }
    } catch (e) {
      _erro(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _enviarLogin() async {
    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _erro('Preencha e-mail e senha.');
      return;
    }
    _erro('Login ainda não implementado.');
  }

  void _erro(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A4A), // Fundo combinando com a gaveta
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Atenção',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Fecha o pop-up
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF1E90FF), fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  bool get _isCadastro => widget.tipo == 'cadastro';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82 + bottomInset,
      decoration: BoxDecoration(
        // Fundo mais sólido para os campos ficarem destacados
        color: const Color(0xFF1A2A4A).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Barrinha de puxador
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
                  Text(
                    _isCadastro ? 'Cadastro' : 'Login',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                      children: _isCadastro
                          ? const [
                        TextSpan(text: 'Crie sua conta e comece investir\nem startups com o '),
                        TextSpan(
                          text: 'MesclaInvest',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ]
                          : const [
                        TextSpan(text: 'Bem-vindo de volta ao '),
                        TextSpan(
                          text: 'MesclaInvest',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (_isCadastro) ...[
                    CampoTexto(label: 'Nome Completo', controller: _nomeController),
                    const SizedBox(height: 12),
                  ],

                  CampoTexto(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  if (_isCadastro) ...[
                    CampoTexto(label: 'CPF', controller: _cpfController, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    CampoTexto(label: 'Celular', controller: _celularController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                  ],

                  CampoTexto(label: 'Senha', controller: _senhaController, obscureText: true),
                  const SizedBox(height: 12),

                  if (_isCadastro) ...[
                    CampoTexto(label: 'Confirmar senha', controller: _confirmarSenhaController, obscureText: true),
                  ],

                  const SizedBox(height: 28),

                  _carregando
                      ? const CircularProgressIndicator(color: Color(0xFF1E90FF))
                      : BotaoPrimario(
                    texto: _isCadastro ? 'Enviar' : 'Entrar',
                    isPrimary: true,
                    onPressed: _isCadastro ? _enviarCadastro : _enviarLogin,
                  ),

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
                            builder: (_) => _GavetaFormulario(
                              tipo: _isCadastro ? 'login' : 'cadastro',
                            ),
                          );
                        }
                      });
                    },
                    child: Text(
                      _isCadastro ? 'Já tem conta? Faça login' : 'Não tem conta? Cadastre-se',
                      style: const TextStyle(color: Colors.white70),
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