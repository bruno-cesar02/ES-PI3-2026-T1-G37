/* Bruno César Gonçalves Lima Mota
   RA: 24795502
   Modal para simulação de investimento (compra de tokens). */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../services/StartupDetails_service.dart';
import '../../theme/app_colors.dart';

class ModalInvestimento extends StatefulWidget {
  final Startup startup;
  const ModalInvestimento({super.key, required this.startup});

  @override
  State<ModalInvestimento> createState() => _ModalInvestimentoState();
}

class _ModalInvestimentoState extends State<ModalInvestimento> {
  final _controller = TextEditingController();
  bool _success = false;
  bool _isLoading = false;
  int _tokensToGet = 0;
  double _amountNum = 0;

  static const _quickAmounts = ['R\$ 100', 'R\$ 500', 'R\$ 1.000', 'R\$ 5.000'];
  String? _selectedQuick;

  double get _pricePerToken => widget.startup.tokenPriceValue;

  void _calcular(String val) {
    final clean = val.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.');
    final num = double.tryParse(clean) ?? 0;
    setState(() { _amountNum = num; _tokensToGet = _pricePerToken > 0 ? (num / _pricePerToken).floor() : 0; });
  }

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);

    try {
      // O backend trabalha com centavos para evitar erros de ponto flutuante
      final currentPriceCents = (widget.startup.tokenPriceValue * 100).round();
      final totalPriceCents = _tokensToGet * currentPriceCents;

      // Chama a function de compra
      await StartupService.instance.buyStartupToken(
        startupId: widget.startup.id,
        startupName: widget.startup.nome,
        currentTokenPriceCents: currentPriceCents,
        tokenAmount: _tokensToGet,
        totalPriceCents: totalPriceCents,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _success = true;
        });

        // Retorna 'true' ao fechar o modal para que a tela de detalhes saiba que precisa recarregar os dados
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao comprar tokens: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => _success ? _buildSuccess() : _buildForm();

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.positive.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.positive, size: 40)),
        const SizedBox(height: 16),
        const Text('Investimento realizado!', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('$_tokensToGet tokens adicionados à sua carteira.', style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
      ]),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Simular Investimento', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            Text('${widget.startup.nome} · ${widget.startup.tokenPrice}/token', style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          ]),
          GestureDetector(onTap: () => Navigator.pop(context), child: Container(
            width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF666666)),
          )),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: _quickAmounts.map((q) {
          final active = _selectedQuick == q;
          return GestureDetector(
            onTap: () { setState(() => _selectedQuick = q); _controller.text = q.replaceAll('R\$ ', '').replaceAll('.', ''); _calcular(_controller.text); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFF5F6F8),
                border: Border.all(color: active ? AppColors.primary : Colors.transparent), borderRadius: BorderRadius.circular(12),
              ),
              child: Text(q, style: TextStyle(color: active ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),
        const Text('Valor a investir (R\$)', style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: _calcular,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF5F6F8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (_tokensToGet > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tokens a receber', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text('$_tokensToGet', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Valor total', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text(_formatBRL(_tokensToGet * _pricePerToken), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _tokensToGet > 0 ? _confirmar : null,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: _tokensToGet > 0 ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]) : null,
              color: _tokensToGet > 0 ? null : const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(24),
              boxShadow: _tokensToGet > 0 ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))] : null,
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                _tokensToGet > 0 ? 'Confirmar · $_tokensToGet tokens' : 'Informe um valor',
                style: TextStyle(color: _tokensToGet > 0 ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('⚠️ Operação simulada · Sem envolvimento de ativos reais',
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11), textAlign: TextAlign.center)),
      ]),
    );
  }

  String _formatBRL(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final buf = StringBuffer();
    final intPart = parts[0];
    for (var i = 0; i < intPart.length; i++) { if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.'); buf.write(intPart[i]); }
    return 'R\$ $buf,${parts[1]}';
  }
}
