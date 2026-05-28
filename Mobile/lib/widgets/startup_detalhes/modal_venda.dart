/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Modal para criar oferta de venda no balcão a partir da tela de detalhes da startup.
   Atalho: a startup já vem do contexto (widget.startup), sem precisar selecionar. */

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../theme/app_colors.dart';

class ModalVenda extends StatefulWidget {
  final Startup startup;
  const ModalVenda({super.key, required this.startup});

  @override
  State<ModalVenda> createState() => _ModalVendaState();
}

class _ModalVendaState extends State<ModalVenda> {
  final _qtdController = TextEditingController();
  final _precoController = TextEditingController();

  bool _success = false;
  bool _isLoading = false;
  int _tokensToSell = 0;
  double _precoUnitario = 0;

  String? _selectedQuick;

  int get _tokensDisponiveis => widget.startup.userTokensOwned;
  double get _precoBase => widget.startup.tokenPriceValue;
  double get _valorTotal => _tokensToSell * _precoUnitario;

  double get _variacao {
    if (_precoBase <= 0) return 0;
    return ((_precoUnitario - _precoBase) / _precoBase) * 100;
  }

  // Quick amounts inteligentes: só mostra valores que o usuário tem
  List<int> get _quickAmounts {
    if (_tokensDisponiveis <= 0) return [];
    final all = [10, 50, 100, 500];
    return all.where((v) => v <= _tokensDisponiveis).toList();
  }

  bool get _excedeSaldo => _tokensToSell > _tokensDisponiveis;
  bool get _canConfirm =>
      _tokensToSell > 0 && _precoUnitario > 0 && !_excedeSaldo;

  void _calcularQtd(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final n = int.tryParse(clean) ?? 0;
    setState(() => _tokensToSell = n);
  }

  void _calcularPreco(String val) {
    final clean = val.replaceAll(',', '.');
    final n = double.tryParse(clean) ?? 0;
    setState(() => _precoUnitario = n);
  }

  void _venderTudo() {
    _qtdController.text = _tokensDisponiveis.toString();
    setState(() => _selectedQuick = null);
    _calcularQtd(_qtdController.text);
  }

  void _usarPrecoBase() {
    _precoController.text = _precoBase.toStringAsFixed(2).replaceAll('.', ',');
    _calcularPreco(_precoController.text);
  }

  Future<void> _confirmar() async {
    if (!_canConfirm) return;
    setState(() => _isLoading = true);

    // TODO: Quando o BalcaoService.criarOferta() existir, a chamada real entra aqui.
    // Por enquanto só logamos pra confirmar que os valores estão certos.
    debugPrint('━━━━━━ Criando Oferta no Balcão ━━━━━━');
    debugPrint('Startup: ${widget.startup.nome} (id: ${widget.startup.id})');
    debugPrint('Quantidade: $_tokensToSell tokens');
    debugPrint('Preço unitário: R\$ ${_precoUnitario.toStringAsFixed(2)}');
    debugPrint('Preço base: R\$ ${_precoBase.toStringAsFixed(2)}');
    debugPrint('Variação vs base: ${_variacao.toStringAsFixed(2)}%');
    debugPrint('Valor total: R\$ ${_valorTotal.toStringAsFixed(2)}');

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _success = true;
      });
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) Navigator.pop(context, true);
      });
    }
  }

  @override
  void dispose() {
    _qtdController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _success ? _buildSuccess() : _buildForm();

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'Oferta publicada no balcão!',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '$_tokensToSell tokens de ${widget.startup.nome} disponíveis para outros investidores.',
          style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Criar Oferta de Venda',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                Text('${widget.startup.nome} · base ${widget.startup.tokenPrice}/token',
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFF5F6F8), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF666666)),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // Banner: tokens disponíveis + Vender tudo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(children: [
                const Icon(Icons.toll_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                const Text('Você possui', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                const Spacer(),
                Text('$_tokensDisponiveis ${_tokensDisponiveis == 1 ? "token" : "tokens"}',
                    style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _tokensDisponiveis > 0 && !_isLoading ? _venderTudo : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _tokensDisponiveis > 0 ? AppColors.primary : Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Vender tudo',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Quick amounts (quantidade)
            if (_quickAmounts.isNotEmpty) ...[
              Wrap(spacing: 8, runSpacing: 8, children: _quickAmounts.map((q) {
                final active = _selectedQuick == q.toString();
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedQuick = q.toString());
                    _qtdController.text = q.toString();
                    _calcularQtd(_qtdController.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : const Color(0xFFF5F6F8),
                      border: Border.all(color: active ? AppColors.primary : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$q tokens',
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w500,
                        )),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
            ],

            // Campo quantidade
            const Text('Quantidade de tokens',
                style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _qtdController,
              keyboardType: TextInputType.number,
              onChanged: _calcularQtd,
              enabled: _tokensDisponiveis > 0,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true, fillColor: const Color(0xFFF5F6F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _excedeSaldo ? AppColors.negative : AppColors.primary, width: 1.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _excedeSaldo ? AppColors.negative : AppColors.primary, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _excedeSaldo ? AppColors.negative : AppColors.primary, width: 1.5)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixText: 'Tokens',
                suffixStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (_excedeSaldo) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Você possui apenas $_tokensDisponiveis ${_tokensDisponiveis == 1 ? "token" : "tokens"}.',
                  style: const TextStyle(color: AppColors.negative, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Label do campo preço + atalho "usar preço base"
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Preço por token (R\$)',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: _tokensDisponiveis > 0 ? _usarPrecoBase : null,
                child: const Text('Usar preço base',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12, fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ]),
            const SizedBox(height: 6),
            TextField(
              controller: _precoController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: _calcularPreco,
              enabled: _tokensDisponiveis > 0,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true, fillColor: const Color(0xFFF5F6F8),
                hintText: '0,00',
                hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixText: 'R\$ ',
                prefixStyle: const TextStyle(color: Color(0xFF666666), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            // Resumo em tempo real (valor total + variação vs base)
            if (_tokensToSell > 0 && !_excedeSaldo && _precoUnitario > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Valor total da oferta',
                        style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                    Text(_formatBRL(_valorTotal),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Variação vs. base',
                        style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                    Text(
                      '${_variacao >= 0 ? '+' : ''}${_variacao.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: _variacao >= 0 ? AppColors.positive : AppColors.negative,
                        fontSize: 14, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
                ]),
              ),
            ],
            const SizedBox(height: 16),

            // Botão publicar
            GestureDetector(
              onTap: _canConfirm && !_isLoading ? _confirmar : null,
              child: Container(
                width: double.infinity, height: 56,
                decoration: BoxDecoration(
                  gradient: _canConfirm
                      ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
                      : null,
                  color: _canConfirm ? null : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: _canConfirm
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]
                      : null,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    _excedeSaldo
                        ? 'Quantidade indisponível'
                        : _tokensToSell > 0 && _precoUnitario > 0
                        ? 'Publicar Oferta · $_tokensToSell ${_tokensToSell == 1 ? "token" : "tokens"}'
                        : 'Informe quantidade e preço',
                    style: TextStyle(
                      color: _canConfirm ? Colors.white : Colors.white.withOpacity(0.4),
                      fontSize: 16, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '⚠️ Operação simulada · Sem envolvimento de ativos reais',
                style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
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