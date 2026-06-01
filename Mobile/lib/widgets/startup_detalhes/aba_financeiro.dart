/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Aba Financeiro — métricas financeiras e botões de compra/venda de tokens. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../theme/app_colors.dart';
import 'detalhes_helpers.dart';
import 'modal_investimento.dart';
import 'modal_venda.dart';

class AbaFinanceiro extends StatelessWidget {
  final Startup startup;
  final bool isInvestor;
  final bool canTradeTokens;
  final int walletBalanceCents;
  final VoidCallback onTransacaoConcluida;

  const AbaFinanceiro({
    super.key,
    required this.startup,
    required this.isInvestor,
    required this.canTradeTokens,
    required this.walletBalanceCents,
    required this.onTransacaoConcluida,
  });

  @override
  Widget build(BuildContext context) {
    final cpvNum = double.tryParse(startup.cpv.replaceAll('%', '').replaceAll(',', '.').trim()) ?? 0;
    final cpvFraction = (cpvNum / 100).clamp(0.0, 1.0);

    return ListView(padding: const EdgeInsets.all(16), children: [
      GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4, children: [
            _FinCard(label: 'Capital Aportado', valor: startup.capitalAportado, sub: 'Simulado'),
            _FinCard(label: 'Tokens Emitidos', valor: _formatTokens(startup.tokensEmitidos), sub: 'Total'),
          ]),
      const SizedBox(height: 12),
      if (isInvestor) ...[
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.positive.withOpacity(0.08),
                border: Border.all(color: AppColors.positive.withOpacity(0.2)), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.positive, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Você é investidor desta startup',
                    style: TextStyle(color: AppColors.positive, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Você possui ${startup.userTokensOwned} ${startup.userTokensOwned == 1 ? "token" : "tokens"}',
                    style: TextStyle(color: AppColors.positive.withOpacity(0.85), fontSize: 12)),
              ])),
            ])),
      ],
      const SizedBox(height: 24),
      Row(
        children: [
          // Botão Comprar — sempre disponível
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    builder: (_) => ModalInvestimento(
                      startup: startup,
                      walletBalanceCents: walletBalanceCents,
                    )
                );
                if (result == true) onTransacaoConcluida();
              },
              child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))]
                  ),
                  child: const Center(
                      child: Text('Comprar', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))
                  )
              ),
            ),
          ),
          // Botão Vender — SÓ se for investidor E puder negociar
          if (isInvestor && canTradeTokens) ...[
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                      builder: (_) => ModalVenda(startup: startup)
                  );
                  if (result == true) onTransacaoConcluida();
                },
                child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 2),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                        child: Text('Vender', style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w700))
                    )
                ),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 16),
    ]);
  }

  String _formatTokens(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _FinCard extends StatelessWidget {
  final String label, valor, sub;
  const _FinCard({required this.label, required this.valor, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.cardBg, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Color(0xFF515151), fontSize: 11)),
          const SizedBox(height: 4),
          Text(valor, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: Color(0xFF707070), fontSize: 10)),
        ]));
  }
}