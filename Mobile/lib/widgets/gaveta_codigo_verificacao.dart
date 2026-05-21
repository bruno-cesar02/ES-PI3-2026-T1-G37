import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'gaveta_redefinir_senha.dart';

class GavetaCodigoVerificacao extends StatelessWidget {
  const GavetaCodigoVerificacao({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final TextEditingController codigoController = TextEditingController();

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
              borderRadius: BorderRadius.circular(10)
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottomInset + 16),
              child: Column(
                children: [
                  const Text(
                    'Verificação', 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Insira o código enviado ao seu e-mail', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.white70, fontSize: 14)
                  ),
                  const SizedBox(height: 28),
                  CampoTexto(
                    label: 'Código de 6 dígitos', 
                    controller: codigoController, 
                    keyboardType: TextInputType.number
                  ),
                  const SizedBox(height: 28),
                  BotaoPrimario(
                    texto: 'Verificar',
                    isPrimary: true,
                    onPressed: () {
                    
                      final navigator = Navigator.of(context);

                      navigator.pop();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (navigator.context.mounted) {
                          showModalBottomSheet(
                            context: navigator.context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const GavetaRedefinirSenha(),
                          );
                        }
                      });
                    },
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