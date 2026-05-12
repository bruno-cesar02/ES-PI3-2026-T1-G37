/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Aba Mídia — vídeos demonstrativos e materiais. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../theme/app_colors.dart';
import 'detalhes_helpers.dart';

class AbaMidia extends StatelessWidget {
  final Startup startup;
  final List<String> demoVideos;
  final String? pitchDeckUrl;

  const AbaMidia({super.key, required this.startup, required this.demoVideos, required this.pitchDeckUrl});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      ..._buildVideoCards(),
      if (pitchDeckUrl != null || startup.materiais.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.only(left: 4, top: 4, bottom: 8),
          child: Text('Materiais Adicionais', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700))),
        if (pitchDeckUrl != null) const _MaterialCard(titulo: 'Deck de Investimento', tipo: 'PDF', tamanho: '-'),
        ...startup.materiais.map((m) => _MaterialCard(titulo: m.titulo, tipo: m.tipo, tamanho: m.tamanho)),
      ],
      const SizedBox(height: 16),
    ]);
  }

  List<Widget> _buildVideoCards() {
    final videos = demoVideos.isNotEmpty
      ? demoVideos.asMap().entries.map((e) => _VideoCard(
          title: e.key == 0 ? 'Vídeo Demonstrativo' : 'Apresentação ${e.key + 1}',
          subtitle: 'Pitch da ${startup.nome}', duration: '--:--', url: e.value)).toList()
      : [_VideoCard(title: 'Vídeo Demonstrativo', subtitle: 'Pitch principal da ${startup.nome}', duration: '5:32', url: null),
         const _VideoCard(title: 'Apresentação dos Sócios', subtitle: 'Entrevista com os fundadores', duration: '3:15', url: null)];
    return videos.map((v) => Padding(padding: const EdgeInsets.only(bottom: 12), child: v)).toList();
  }
}

class _VideoCard extends StatelessWidget {
  final String title, subtitle, duration;
  final String? url;
  const _VideoCard({required this.title, required this.subtitle, required this.duration, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.cardBg, border: Border.all(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 144, width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            Container(decoration: const BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF020C14), Color(0xFF0F2050)]))),
            Center(child: Container(width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)]),
              child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 30))),
            Positioned(left: 12, bottom: 12,
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(999)),
                child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 11)))),
          ])),
        Padding(padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
          ])),
      ]));
  }
}

class _MaterialCard extends StatelessWidget {
  final String titulo, tipo, tamanho;
  const _MaterialCard({required this.titulo, required this.tipo, required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 12),
      child: DetalhesCard(padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFFE53E3E), size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            Text('$tipo · $tamanho', style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
          ])),
          Container(width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.download_rounded, color: AppColors.primary, size: 16)),
        ])));
  }
}
