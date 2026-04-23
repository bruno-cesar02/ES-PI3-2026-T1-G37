import 'package:flutter/material.dart';
import 'dart:ui'; // Necessário para o efeito de blur

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Cores do degradê do Figma (Azul escuro para preto)
            colors: [Color(0xFF001A72), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            //logo temporária
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white),
            const Text(
              "Mescla Invest",
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efeito de desfoque
                child: Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.2)), // Borda sutil
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Recuperar senha",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      // Input de E-mail
                      TextField(
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2), // Fundo do input
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 25),
                      // Botão "Enviar"
                      SizedBox(
                        width: 220,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            // Lógica de envio futura
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E90FF), // Cor azul do Figma
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text("Enviar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // Botão "Voltar"
                      SizedBox(
                        width: 220,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context), // Lógica de voltar funcional
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.8), // Fundo cinza/branco
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.black.withOpacity(0.1)), // Borda sutil
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text("Voltar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}