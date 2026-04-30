/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import 'package:flutter/material.dart';
import '../widgets/botao_primario.dart';
import '../widgets/gaveta_cadastro.dart'; // IMPORTA AQUI
import '../widgets/gaveta_login.dart';    // IMPORTA AQUI

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  State<TelaInicialScreen> createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  bool _mostrarBotoes = true;

  void _abrirGaveta(Widget gaveta) async { // Agora recebe um Widget
    setState(() => _mostrarBotoes = false);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => gaveta, // Mostra o widget que você passar
    );

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 39),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  AnimatedOpacity(
                    opacity: _mostrarBotoes ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !_mostrarBotoes,
                      child: Column(
                        children: [
                          BotaoPrimario(
                            texto: 'Cadastro',
                            isPrimary: true,
                            onPressed: () => _abrirGaveta(const GavetaCadastro()), // Chama o arquivo de Cadastro
                          ),
                          const SizedBox(height: 16),
                          BotaoPrimario(
                            texto: 'Login no MesclaInvest',
                            isPrimary: false,
                            onPressed: () => _abrirGaveta(const GavetaLogin()), // Chama o arquivo de Login
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