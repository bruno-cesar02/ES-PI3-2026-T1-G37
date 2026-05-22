import 'package:flutter/material.dart';

// ------------------------------------------------------------------------
// MODELOS (Prontos para mapear do Firestore)
// ------------------------------------------------------------------------
class Oferta {
  final String id;
  final String startupId;
  final String startupNome;
  final String logoUrl;
  final String tipo; // 'venda' ou 'compra'
  final int tokens;
  final double precoUnitario;
  final double variacaoPercent;
  final bool isMinha;

  Oferta({
    required this.id,
    required this.startupId,
    required this.startupNome,
    required this.logoUrl,
    required this.tipo,
    required this.tokens,
    required this.precoUnitario,
    required this.variacaoPercent,
    this.isMinha = false,
  });
}

// ------------------------------------------------------------------------
// TELA PRINCIPAL
// ------------------------------------------------------------------------
class BalcaoTokensScreen extends StatefulWidget {
  const BalcaoTokensScreen({super.key});

  @override
  State<BalcaoTokensScreen> createState() => _BalcaoTokensScreenState();
}

class _BalcaoTokensScreenState extends State<BalcaoTokensScreen> {
  String _tabSelecionada = 'comprar';
  String _search = '';

  // Dados mockados para simular o estado do React
  final double _volumeTotal = 25430.00;
  final double _variacaoMedia = 4.2;

  final List<Oferta> _ofertasMock = [
    Oferta(
      id: 'v001',
      startupId: 'eduflex',
      startupNome: 'EduFlex',
      logoUrl: 'https://via.placeholder.com/150',
      tipo: 'venda',
      tokens: 300,
      precoUnitario: 13.9,
      variacaoPercent: 4.3,
    ),
    Oferta(
      id: 'm001',
      startupId: 'karpos',
      startupNome: 'Karpós S.A',
      logoUrl: 'https://via.placeholder.com/150',
      tipo: 'venda',
      tokens: 50,
      precoUnitario: 15.0,
      variacaoPercent: 5.2,
      isMinha: true,
    ),
  ];

  List<Oferta> get _ofertasFiltradas {
    List<Oferta> base;
    if (_tabSelecionada == 'comprar') {
      base = _ofertasMock.where((o) => o.tipo == 'venda' && !o.isMinha).toList();
    } else if (_tabSelecionada == 'vender') {
      base = _ofertasMock.where((o) => o.tipo == 'compra' && !o.isMinha).toList();
    } else {
      base = _ofertasMock.where((o) => o.isMinha).toList();
    }

    if (_search.isEmpty) return base;
    return base.where((o) => o.startupNome.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  void _abrirSheetTransacao(Oferta oferta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransacaoSheet(
        oferta: oferta,
        modo: _tabSelecionada,
        onConfirmar: (qtd) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Transação de $qtd tokens processada com sucesso!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020C14),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mercado secundário',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                  ),
                  const Text(
                    'Balcão de Tokens',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Card de Estatísticas
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2050), Color(0xFF1A3A8F), Color(0xFF0F2050)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF386BF6).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text('Mercado ativo agora', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF00AE51).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Text('AO VIVO', style: TextStyle(color: Color(0xFF00AE51), fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn('Volume 24h', 'R\$ ${_volumeTotal.toStringAsFixed(2)}'),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                      _buildStatColumn('Ofertas ativas', '24'),
                      Container(width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
                      _buildStatColumn('Var. média', '+${_variacaoMedia.toStringAsFixed(1)}%', color: const Color(0xFF00AE51)),
                    ],
                  )
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    _buildTab('Comprar', 'comprar'),
                    _buildTab('Vender', 'vender'),
                    _buildTab('Minhas', 'minhas'),
                  ],
                ),
              ),
            ),

            // Search (Apenas se não for 'minhas')
            if (_tabSelecionada != 'minhas')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _search = val),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            icon: Icon(Icons.search, color: Colors.white.withOpacity(0.35), size: 18),
                            hintText: 'Buscar startup...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (_tabSelecionada == 'vender') ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          // TODO: Abrir Sheet de Nova Oferta
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: const Color(0xFF386BF6), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      )
                    ]
                  ],
                ),
              ),

            // Lista de Ofertas
            Expanded(
              child: _ofertasFiltradas.isEmpty
                  ? const Center(
                  child: Text('Nenhuma oferta encontrada.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _ofertasFiltradas.length,
                itemBuilder: (context, index) {
                  final oferta = _ofertasFiltradas[index];
                  return _OfertaCard(
                    oferta: oferta,
                    onPress: () => _abrirSheetTransacao(oferta),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, {Color color = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTab(String title, String id) {
    final isSelected = _tabSelecionada == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabSelecionada = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF386BF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF386BF6).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// WIDGET CARD DE OFERTA
// ------------------------------------------------------------------------
class _OfertaCard extends StatelessWidget {
  final Oferta oferta;
  final VoidCallback onPress;

  const _OfertaCard({required this.oferta, required this.onPress});

  @override
  Widget build(BuildContext context) {
    final total = oferta.tokens * oferta.precoUnitario;
    final isPositive = oferta.variacaoPercent >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: oferta.isMinha ? const Color(0xFF386BF6).withOpacity(0.07) : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: oferta.isMinha ? const Color(0xFF386BF6).withOpacity(0.25) : Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: NetworkImage(oferta.logoUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oferta.startupNome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${oferta.tokens} tokens', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('R\$ ${oferta.precoUnitario.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: isPositive ? const Color(0xFF00AE51) : Colors.red, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? '+' : ''}${oferta.variacaoPercent}%',
                        style: TextStyle(color: isPositive ? const Color(0xFF00AE51) : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Divider(color: Colors.white.withOpacity(0.07), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: R\$ ${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11)),
              if (oferta.isMinha)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.15), minimumSize: const Size(80, 30)),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 11)),
                )
              else
                ElevatedButton(
                  onPressed: onPress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oferta.tipo == 'venda' ? const Color(0xFF386BF6).withOpacity(0.2) : const Color(0xFF00AE51).withOpacity(0.2),
                    elevation: 0,
                    minimumSize: const Size(80, 30),
                  ),
                  child: Text(
                    oferta.tipo == 'venda' ? 'Comprar' : 'Vender',
                    style: TextStyle(color: oferta.tipo == 'venda' ? const Color(0xFF386BF6) : const Color(0xFF00AE51), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------------
// BOTTOM SHEET DE TRANSAÇÃO (Simplificado)
// ------------------------------------------------------------------------
class _TransacaoSheet extends StatefulWidget {
  final Oferta oferta;
  final String modo; // 'comprar' ou 'vender'
  final Function(int) onConfirmar;

  const _TransacaoSheet({required this.oferta, required this.modo, required this.onConfirmar});

  @override
  State<_TransacaoSheet> createState() => _TransacaoSheetState();
}

class _TransacaoSheetState extends State<_TransacaoSheet> {
  int _qtd = 10;

  @override
  Widget build(BuildContext context) {
    final total = _qtd * widget.oferta.precoUnitario;
    final isBuy = widget.modo == 'comprar';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(isBuy ? 'Comprar Tokens' : 'Vender Tokens', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
            Text('${widget.oferta.startupNome} • R\$ ${widget.oferta.precoUnitario}/token', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Quantidade de tokens', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 8),
            Row(
              children: [5, 10, 25, 50].map((v) {
                final selected = _qtd == v;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _qtd = v),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF386BF6) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(v.toString(), style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF386BF6))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => widget.onConfirmar(_qtd),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBuy ? const Color(0xFF386BF6) : const Color(0xFF00AE51),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                isBuy ? 'Confirmar Compra' : 'Confirmar Venda',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}