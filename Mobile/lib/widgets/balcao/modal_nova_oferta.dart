import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/balcao_service.dart';

class ModalNovaOferta extends StatefulWidget {
  const ModalNovaOferta({Key? key}) : super(key: key);

  @override
  State<ModalNovaOferta> createState() => _ModalNovaOfertaState();
}

class _ModalNovaOfertaState extends State<ModalNovaOferta> {
  final _qtdController = TextEditingController();
  final _precoController = TextEditingController();

  bool confirmado = false;
  bool _isLoading = false;
  bool _isLoadingData = true; // Controla o loading inicial da carteira

  List<Map<String, dynamic>> _minhasStartups = [];
  String? _startupSelecionadaId;

  @override
  void initState() {
    super.initState();
    _qtdController.addListener(() => setState(() {}));
    _precoController.addListener(() => setState(() {}));
    _carregarCarteira();
  }

  // Função que vai no Firebase buscar SÓ o que você realmente tem
  Future<void> _carregarCarteira() async {
    final tokens = await BalcaoService().fetchMeusTokensParaVenda();
    if (mounted) {
      setState(() {
        _minhasStartups = tokens;
        if (_minhasStartups.isNotEmpty) {
          _startupSelecionadaId = _minhasStartups[0]['id'];
        }
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _qtdController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  int? get _qtd => int.tryParse(_qtdController.text);
  double? get _preco {
    if (_precoController.text.isEmpty) return null;
    return double.tryParse(_precoController.text.replaceAll(',', '.'));
  }

  int get _disponiveis {
    if (_minhasStartups.isEmpty) return 0;
    final s = _minhasStartups.firstWhere(
          (s) => s['id'] == _startupSelecionadaId,
      orElse: () => _minhasStartups.first,
    );
    return s['disponiveis'] as int;
  }

  bool get _isValid {
    final q = _qtd;
    final p = _preco;
    if (q == null || q <= 0) return false;
    if (q > _disponiveis) return false;
    if (p == null || p <= 0) return false;
    return true;
  }

  Future<void> _publicarOferta() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    final startupSelecionada = _minhasStartups.firstWhere(
          (s) => s['id'] == _startupSelecionadaId,
    );

    try {
      await BalcaoService().criarOferta(
        startupId: startupSelecionada['id'],
        quantity: _qtd!,
        purchasePriceCents: (_preco! * 100).round(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          confirmado = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Erro ao publicar oferta: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48, height: 6,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 24),

            // ─── LÓGICA DE EXIBIÇÃO: Loading > Vazio > Formulário ───
            if (_isLoadingData)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: CircularProgressIndicator(color: Color(0xFF386BF6))),
              )
            else if (_minhasStartups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Column(
                  children: [
                    const Icon(Icons.toll_outlined, size: 64, color: Color(0xFFCBD5E1)),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Você não possui tokens para venda.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), elevation: 0),
                      child: const Text('Voltar', style: TextStyle(color: Color(0xFF64748B))),
                    )
                  ],
                ),
              )
            else if (confirmado) ...[
                const Center(child: CircleAvatar(radius: 32, backgroundColor: Color(0x1F00AE51), child: Icon(Icons.assignment_turned_in, color: Color(0xFF00AE51), size: 32))),
                const SizedBox(height: 16),
                const Center(child: Text('Oferta publicada com sucesso!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14)))),
                const SizedBox(height: 8),
                const Center(child: Text('Seus tokens estão agora em custódia.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B)))),
                const SizedBox(height: 24),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Criar Oferta de Venda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
                        Text('Coloque seus tokens à venda no balcão', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text('Selecione a startup', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Column(
                  children: _minhasStartups.map((s) {
                    final bool isSelected = _startupSelecionadaId == s['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _startupSelecionadaId = s['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF386BF6).withOpacity(0.05) : const Color(0xFFF8FAFC),
                          border: Border.all(color: isSelected ? const Color(0xFF386BF6) : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  s['nome'].toString().substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF386BF6)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['nome'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
                                  Text('${s['disponiveis']} tokens disponíveis', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 24, height: 24,
                                decoration: const BoxDecoration(color: Color(0xFF386BF6), shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: Colors.white, size: 16),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                Builder(
                    builder: (context) {
                      final startupSelecionada = _minhasStartups.firstWhere(
                            (s) => s['id'] == _startupSelecionadaId,
                        orElse: () => _minhasStartups.first,
                      );
                      final int disponiveis = startupSelecionada['disponiveis'];
                      final double precoBase = startupSelecionada['precoBase'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantidade ($disponiveis disponíveis)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _qtdController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(color: Color(0xFF020C14), fontSize: 18, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF386BF6))),
                            ),
                          ),
                          if (_qtd != null && _qtd! > disponiveis)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 4),
                              child: Text(
                                'Você só tem $disponiveis tokens disponíveis',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 16),

                          Text('Preço por token (base: R\$ ${precoBase.toStringAsFixed(2).replaceAll('.', ',')})', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _precoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d*'))],
                            style: const TextStyle(color: Color(0xFF020C14), fontSize: 18, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: '0,00',
                              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF386BF6))),
                            ),
                          ),
                          if (_qtd != null && _qtd! > 0 && _preco != null && _preco! > 0) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Valor total da oferta', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                                      Text('R\$ ${(_qtd! * _preco!).toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Color(0xFF020C14), fontSize: 15, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Builder(builder: (_) {
                                    final variacao = ((_preco! - precoBase) / precoBase) * 100;
                                    final positiva = variacao >= 0;
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Variação vs. base', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                                        Text('${positiva ? '+' : ''}${variacao.toStringAsFixed(1)}%',
                                            style: TextStyle(color: positiva ? const Color(0xFF00AE51) : Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF386BF6),
                              disabledBackgroundColor: const Color(0xFF386BF6).withOpacity(0.4),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: _isValid && !_isLoading ? _publicarOferta : null,
                            child: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Publicar Oferta', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    }
                ),
              ],
          ],
        ),
      ),
    );
  }
}