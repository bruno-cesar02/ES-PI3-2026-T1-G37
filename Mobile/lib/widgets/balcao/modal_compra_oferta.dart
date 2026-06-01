/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
import 'package:flutter/material.dart';
import '../../models/oferta_model.dart';
import '../../services/balcao_service.dart';

class ModalCompraOferta extends StatefulWidget {
  final OfertaModel oferta;
  const ModalCompraOferta({Key? key, required this.oferta}) : super(key: key);

  @override
  State<ModalCompraOferta> createState() => _ModalCompraOfertaState();
}

class _ModalCompraOfertaState extends State<ModalCompraOferta> {
  bool confirmado = false;

  void _confirmarCompra() async {
    try {
      await BalcaoService().aceitarOferta(
        exchangeId: widget.oferta.id,
        startupId: widget.oferta.startupId,
      );
      setState(() => confirmado = true);
      Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context, true));
    } catch (e) {
      // Aqui você pode colocar uma notificação de erro, ex: "Saldo insuficiente"
    }
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.oferta.tokens * widget.oferta.precoUnitario;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 24),

          if (confirmado) ...[
            const CircleAvatar(radius: 32, backgroundColor: Color(0x1F00AE51), child: Icon(Icons.check, color: Color(0xFF00AE51), size: 32)),
            const SizedBox(height: 16),
            const Text('Compra realizada!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
            const SizedBox(height: 8),
            Text('${widget.oferta.tokens} tokens de ${widget.oferta.startupNome} • R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
            const SizedBox(height: 24),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Comprar Tokens', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
                    Text('${widget.oferta.startupNome} · R\$ ${widget.oferta.precoUnitario.toStringAsFixed(2)}/token', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tokens do lote', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      Text('${widget.oferta.tokens}', style: const TextStyle(color: Color(0xFF020C14), fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Preço por token', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      Text('R\$ ${widget.oferta.precoUnitario.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF020C14), fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total a pagar', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF386BF6), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF386BF6),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _confirmarCompra,
              child: const Text('Confirmar Compra', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}