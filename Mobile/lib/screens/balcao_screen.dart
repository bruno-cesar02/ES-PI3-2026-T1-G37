/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import 'package:flutter/material.dart';
import '../models/oferta_model.dart';
import '../services/balcao_service.dart';
import '../widgets/balcao/oferta_card.dart';
import '../widgets/balcao/modal_compra_oferta.dart';
import '../widgets/balcao/modal_nova_oferta.dart';

class BalcaoScreen extends StatefulWidget {
  const BalcaoScreen({Key? key}) : super(key: key);

  @override
  State<BalcaoScreen> createState() => _BalcaoScreenState();
}

class _BalcaoScreenState extends State<BalcaoScreen> {
  final BalcaoService _balcaoService = BalcaoService();
  String tab = 'disponiveis'; // 'disponiveis' ou 'minhas'
  String searchQuery = '';

  List<OfertaModel> ofertasDeVenda = [];
  List<OfertaModel> minhasOfertas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => isLoading = true);
    final disponiveis = await _balcaoService.fetchOfertasDisponiveis();
    final minhas = await _balcaoService.fetchMinhasOfertas();
    if (mounted) {
      setState(() {
        ofertasDeVenda = disponiveis;
        minhasOfertas = minhas;
        isLoading = false;
      });
    }
  }

  void _abrirCompraSheet(OfertaModel oferta) async {
    final comprou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModalCompraOferta(oferta: oferta),
    );
    // Se a compra foi concluída com sucesso, recarrega o balcão
    if (comprou == true) {
      _carregarDados();
    }
  }

  void _abrirNovaOfertaSheet() async {
    final criou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModalNovaOferta(),
    );
    // Se a oferta foi criada com sucesso, recarrega o balcão
    if (criou == true) {
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final listaBase = tab == 'disponiveis' ? ofertasDeVenda : minhasOfertas;
    final listaExibida = searchQuery.isEmpty
        ? listaBase
        : listaBase.where((o) =>
        o.startupNome.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
    return Scaffold(
      backgroundColor: const Color(0xFF020C14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020C14),
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mercado secundário', style: TextStyle(color: Colors.white60, fontSize: 14)),
            Text('Balcão de Tokens', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Abas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('Ofertas Disponíveis', 'disponiveis'),
                  _buildTabButton('Minhas Ofertas', 'minhas'),
                ],
              ),
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 18),
                  hintText: 'Buscar startup...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lista de Ofertas com Pull-to-Refresh
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF386BF6)))
                : RefreshIndicator(
              color: const Color(0xFF386BF6),
              backgroundColor: const Color(0xFF020C14),
              onRefresh: _carregarDados, // Ao puxar para baixo, atualiza!
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: listaExibida.length,
                itemBuilder: (context, index) {
                  final oferta = listaExibida[index];
                  return OfertaCard(
                    oferta: oferta,
                    isMinha: tab == 'minhas',
                    onAction: () async {
                      if (tab == 'minhas') {
                        setState(() => isLoading = true);
                        try {
                          await _balcaoService.cancelarOferta(
                            exchangeId: oferta.id,
                            startupId: oferta.startupId,
                          );
                          await _carregarDados();
                        } catch (e) {
                          setState(() => isLoading = false);
                          debugPrint("Erro ao cancelar: $e");
                        }
                      } else {
                        _abrirCompraSheet(oferta);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // BOTÃO DE VOLTA NA TELA!
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF386BF6),
        onPressed: _abrirNovaOfertaSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Criar Oferta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTabButton(String title, String tabValue) {
    final isSelected = tab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = tabValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}