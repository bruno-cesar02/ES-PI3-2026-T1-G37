/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Aba Sócios — estrutura societária, fundadores e mentores. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../theme/app_colors.dart';
import 'detalhes_helpers.dart';

class AbaSocios extends StatelessWidget {
  final Startup startup;
  const AbaSocios({super.key, required this.startup});

  @override
  Widget build(BuildContext context) {
    final comPercentual = startup.socios.where((s) => s.percentual > 0).toList();

    return ListView(padding: const EdgeInsets.all(16), children: [
      DetalhesCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estrutura Societária', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...comPercentual.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 24, height: 24,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: Center(child: Text(s.avatar, style: const TextStyle(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 8),
                Text(s.nome, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
              Text('${s.percentual}%', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(borderRadius: BorderRadius.circular(999),
              child: Container(height: 6, decoration: const BoxDecoration(color: AppColors.border),
                child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: s.percentual / 100,
                  child: Container(decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.positive]),
                    borderRadius: BorderRadius.all(Radius.circular(999))))))),
          ]))),
      ])),
      const SizedBox(height: 12),
      const Padding(padding: EdgeInsets.only(left: 4, bottom: 8),
        child: Text('Fundadores', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
      ...startup.socios.map((s) => Padding(padding: const EdgeInsets.only(bottom: 12),
        child: DetalhesCard(padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 48, height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.background]),
                shape: BoxShape.circle),
              child: Center(child: Text(s.avatar, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.nome, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(s.cargo.split(',').first, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              if (s.descricao.isNotEmpty) ...[const SizedBox(height: 4),
                Text(s.descricao, style: const TextStyle(color: Color(0xFF777777), fontSize: 12, height: 1.5))],
            ])),
          ])))),
      if (startup.mentores.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.only(left: 4, top: 4, bottom: 8),
          child: Text('Conselho e Mentores', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
        ...startup.mentores.map((m) => Padding(padding: const EdgeInsets.only(bottom: 12),
          child: DetalhesCard(padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                child: Center(child: Text(m.avatar, style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w700)))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.nome, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(m.cargo, style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
              ])),
            ])))),
      ],
      const SizedBox(height: 16),
    ]);
  }
}
