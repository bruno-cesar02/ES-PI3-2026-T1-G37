/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Widgets auxiliares reutilizáveis da tela de detalhes. */

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class DetalhesCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const DetalhesCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class Shimmer extends StatelessWidget {
  final double width, height, radius;
  const Shimmer({super.key, required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(width: width, height: height,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(radius)));
  }
}

class HeaderSkeleton extends StatelessWidget {
  const HeaderSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Shimmer(width: 68, height: 68, radius: 16), const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Shimmer(width: 160, height: 20, radius: 6), SizedBox(height: 8),
          Shimmer(width: 120, height: 14, radius: 6), SizedBox(height: 8),
          Shimmer(width: 80, height: 20, radius: 6),
        ])),
      ]),
      const SizedBox(height: 12),
      const Shimmer(width: double.infinity, height: 14, radius: 6),
      const SizedBox(height: 6),
      const Shimmer(width: 200, height: 14, radius: 6),
    ]);
  }
}

class ContentSkeleton extends StatelessWidget {
  const ContentSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10),
        Row(children: List.generate(5, (_) => const Padding(
          padding: EdgeInsets.only(right: 12), child: Shimmer(width: 50, height: 40, radius: 6)))),
        const SizedBox(height: 20),
        const Shimmer(width: double.infinity, height: 100, radius: 16),
        const SizedBox(height: 12),
        const Shimmer(width: double.infinity, height: 80, radius: 16),
      ]));
  }
}

class HeaderErro extends StatelessWidget {
  final VoidCallback onRetry;
  const HeaderErro({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 18), const SizedBox(width: 8),
      const Text('Erro ao carregar', style: TextStyle(color: Colors.white54, fontSize: 13)),
      const Spacer(),
      TextButton(onPressed: onRetry, child: const Text('Tentar novamente', style: TextStyle(color: AppColors.primary, fontSize: 13))),
    ]);
  }
}

class TelaErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;
  const TelaErro({super.key, required this.mensagem, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: Colors.grey, size: 48),
        const SizedBox(height: 12),
        const Text('Não foi possível carregar os dados', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(mensagem, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onRetry,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('Tentar novamente')),
      ])));
  }
}

String buildInitials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
