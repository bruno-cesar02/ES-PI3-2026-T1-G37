import 'package:flutter/material.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';

class GavetaRedefinirSenha extends StatelessWidget {
  const GavetaRedefinirSenha({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final TextEditingController novaSenhaController = TextEditingController();
    final TextEditingController confirmarSenhaController = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82 + bottomInset,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A4A).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Barrinha decorativa oficial
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
                    'Nova Senha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crie uma senha forte para proteger sua conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  
                  CampoTexto(
                    label: 'Nova senha',
                    controller: novaSenhaController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  
                  CampoTexto(
                    label: 'Confirmar senha',
                    controller: confirmarSenhaController,
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  BotaoPrimario(
                    texto: 'Atualizar Senha',
                    isPrimary: true,
                    onPressed: () {
                      print("Senha atualizada com sucesso!");
                      
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senha alterada com sucesso!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  BotaoPrimario(
                    texto: 'Cancelar',
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