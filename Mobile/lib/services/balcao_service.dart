import '../models/oferta_model.dart';

class BalcaoService {
  // Dados mockados para você testar a interface antes do Firebase
  Future<List<OfertaModel>> fetchOfertasDisponiveis() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      OfertaModel(
        id: 'oferta_1',
        startupId: 's_1',
        startupNome: 'Karpos',
        ofertanteNome: 'Investidor Anônimo',
        tokens: 10,
        precoUnitario: 15.50,
        variacaoPercent: 4.5,
      ),
    ];
  }

  Future<List<OfertaModel>> fetchMinhasOfertas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      OfertaModel(
        id: 'oferta_2',
        startupId: 's_2',
        startupNome: 'TechNova',
        ofertanteNome: 'Você',
        tokens: 50,
        precoUnitario: 10.00,
        variacaoPercent: -1.2,
      ),
    ];
  }
}