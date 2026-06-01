/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/
class OfertaModel {
  final String id;
  final String startupId;
  final String startupNome;
  final String ofertanteNome;
  final int tokens;
  final double precoUnitario;
  final double variacaoPercent;

  OfertaModel({
    required this.id,
    required this.startupId,
    required this.startupNome,
    required this.ofertanteNome,
    required this.tokens,
    required this.precoUnitario,
    required this.variacaoPercent,
  });
}