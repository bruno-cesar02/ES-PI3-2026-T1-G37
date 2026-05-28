import 'package:flutter/material.dart';
import '../../models/oferta_model.dart';

class OfertaCard extends StatelessWidget {
  final OfertaModel oferta;
  final bool isMinha;
  final VoidCallback onAction;

  const OfertaCard({
    Key? key,
    required this.oferta,
    required this.isMinha,
    required this.onAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double valorLote = oferta.tokens * oferta.precoUnitario;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMinha ? const Color(0xFF386BF6).withOpacity(0.07) : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: isMinha ? const Color(0xFF386BF6).withOpacity(0.25) : Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oferta.startupNome, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${oferta.tokens} tokens • ${oferta.ofertanteNome}', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('R\$ ${oferta.precoUnitario.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      '${oferta.variacaoPercent >= 0 ? '+' : ''}${oferta.variacaoPercent.toStringAsFixed(2)}%',
                      style: TextStyle(
                          color: oferta.variacaoPercent >= 0 ? const Color(0xFF00AE51) : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600
                      )
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.07)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Valor do lote: R\$ ${valorLote.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMinha ? Colors.red.withOpacity(0.15) : const Color(0xFF386BF6).withOpacity(0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onAction,
                child: Text(
                  isMinha ? 'Cancelar Oferta' : 'Comprar',
                  style: TextStyle(
                    color: isMinha ? Colors.red : const Color(0xFF386BF6),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}