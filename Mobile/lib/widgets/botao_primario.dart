import 'package:flutter/material.dart';

/// Botão reutilizável do MesclaInvest.
///
/// Use [BotaoPrimario] em qualquer tela do app passando:
/// - [texto]: o label do botão
/// - [onPressed]: a função que executa ao clicar
/// - [isPrimary]: true = azul (#1E90FF), false = cinza (#D3D3D3)
class BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool isPrimary;

  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          // Cadastro → azul médio do Figma
          // Login    → cinza escuro semi-transparente
          backgroundColor:
          isPrimary ? const Color(0xFF2D6FBF) : const Color(0xFF8A8A8A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}