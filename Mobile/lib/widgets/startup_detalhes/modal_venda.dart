/* Modal para simulação de venda de tokens. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../services/StartupDetails_service.dart';
import '../../theme/app_colors.dart';

class ModalVenda extends StatefulWidget {
  final Startup startup;
  const ModalVenda({super.key, required this.startup});

  @override
  State<ModalVenda> createState() => _ModalVendaState();
}

class _ModalVendaState extends State<ModalVenda> {
  final _controller = TextEditingController();
  bool _success = false;
  bool _isLoading = false;
  int _tokensToSell = 0;
  double _totalValueToReceive = 0;

  // Botões rápidos de quantidade de tokens em vez de R$
  static const _quickAmounts = ['10', '50', '100', '500'];
  String? _selectedQuick;

  double get _pricePerToken => widget.startup.tokenPriceValue;

  void _calcular(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), ''); // Apenas números inteiros
    final num = int.tryParse(clean) ?? 0;

    // TODO: Adicionar validação se 'num' é maior que o saldo de tokens atual do usuário

    setState(() {
      _tokensToSell = num;
      _totalValueToReceive = num * _pricePerToken;
    });
  }

  Future<void> _confirmar() async {
    setState(() => _isLoading = true);

    try {
      final currentPriceCents = (widget.startup.tokenPriceValue * 100).round();
      final totalPriceCents = _tokensToSell * currentPriceCents;

      await StartupService.instance.sellStartupToken(
        startupId: widget.startup.id,
        startupName: widget.startup.nome,
        currentTokenPriceCents: currentPriceCents,
        tokenAmount: _tokensToSell,
        totalPriceCents: totalPriceCents,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _success = true;
        });
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao vender tokens: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _success ? _buildSuccess() : _buildForm();

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40)),
        const SizedBox(height: 16),
        const Text('Ordem de venda registrada!', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('${_formatBRL(_totalValueToReceive)} creditados na sua carteira.', style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
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
            const Text('Vender Tokens', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
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
            onTap: () {
              setState(() => _selectedQuick = q);
              _controller.text = q;
              _calcular(_controller.text);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFF5F6F8),
                border: Border.all(color: active ? AppColors.primary : Colors.transparent), borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$q tokens', style: TextStyle(color: active ? Colors.white : AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),
        const Text('Quantidade de tokens a vender', style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          onChanged: _calcular,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFFF5F6F8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixText: 'Tokens',
              suffixStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 16, fontWeight: FontWeight.w600)
          ),
        ),
        if (_tokensToSell > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.06), borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tokens a subtrair', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text('-$_tokensToSell', style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Valor a receber', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text(_formatBRL(_totalValueToReceive), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ]),
          ),
        ],
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _tokensToSell > 0 ? _confirmar : null,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: _tokensToSell > 0 ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]) : null,
              color: _tokensToSell > 0 ? null : const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(24),
              boxShadow: _tokensToSell > 0 ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))] : null,
            ),
              child: Center(child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                _tokensToSell > 0 ? 'Vender $_tokensToSell tokens' : 'Informe uma quantidade',
                style: TextStyle(color: _tokensToSell > 0 ? Colors.white : Colors.white.withOpacity(0.4), fontSize: 16, fontWeight: FontWeight.w700),
              )
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
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,${parts[1]}';
  }
}