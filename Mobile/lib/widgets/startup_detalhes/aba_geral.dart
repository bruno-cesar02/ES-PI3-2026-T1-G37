/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Aba Geral — sumário executivo, descrição e preço do token. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../theme/app_colors.dart';
import 'detalhes_helpers.dart';

class AbaGeral extends StatelessWidget {
  final Startup startup;
  const AbaGeral({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ...startup.geral.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DetalhesCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.titulo, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(s.conteudo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6)),
        ])),
      )),
      if (startup.geral.isEmpty)
        Padding(padding: const EdgeInsets.only(bottom: 12),
          child: DetalhesCard(child: Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('Informações em breve.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          )))),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.background, Color(0xFF0F2050)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Preço do Token', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(startup.tokenPrice, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Padding(padding: const EdgeInsets.only(bottom: 4),
              child: Text(startup.variacao, style: TextStyle(
                color: startup.variacaoPositiva ? AppColors.positive : AppColors.negative,
                fontSize: 15, fontWeight: FontWeight.w700))),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
    ]);
  }
}
