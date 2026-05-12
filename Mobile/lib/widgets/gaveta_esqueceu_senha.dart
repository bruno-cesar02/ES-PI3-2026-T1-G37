import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'gaveta_codigo_verificacao.dart';

class GavetaEsqueceuSenha extends StatelessWidget {
  const GavetaEsqueceuSenha({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final TextEditingController emailController = TextEditingController();

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
                  BotaoPrimario(
                    texto: 'Enviar',
                    isPrimary: true,
                    onPressed: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const GavetaCodigoVerificacao(),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  BotaoPrimario(
                    texto: 'Voltar',
                    isPrimary: false,
                    onPressed: () => Navigator.pop(context),
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