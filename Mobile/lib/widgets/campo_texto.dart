/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'package:flutter/material.dart';

/// Campo de texto reutilizável do MesclaInvest.
///
/// Use em qualquer tela que precise de input:
/// - [label]: texto placeholder dentro do campo
/// - [controller]: captura o que o usuário digita
/// - [obscureText]: true = campo de senha (esconde os caracteres)
/// - [keyboardType]: tipo de teclado (email, número, etc.)
class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFFD9D9D9).withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),
    );
  }
}