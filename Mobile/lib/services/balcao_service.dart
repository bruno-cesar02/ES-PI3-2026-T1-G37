import 'package:cloud_functions/cloud_functions.dart';
import '../models/oferta_model.dart';

class BalcaoService {
  final _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  // Variável para evitar duas requisições ao Firebase quando a tela carrega
  Map<String, List<OfertaModel>>? _cacheUltimaBusca;

  Future<void> _buscarAmbos() async {
    final callable = _functions.httpsCallable('listExchanges');
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data);

    List<OfertaModel> parseList(List list) {
      return list.map((e) {
        final map = Map<String, dynamic>.from(e);
        return OfertaModel(
          id: map['id'],
          startupId: map['startupId'],
          startupNome: map['startupNome'],
          ofertanteNome: map['ofertanteNome'],
          tokens: (map['tokens'] as num).toInt(),
          precoUnitario: (map['precoUnitarioCents'] as num) / 100.0,
          variacaoPercent: (map['variacaoPercent'] as num).toDouble(),
        );
      }).toList();
    }

    _cacheUltimaBusca = {
      'disponiveis': parseList(data['disponiveis'] ?? []),
      'minhas': parseList(data['minhas'] ?? []),
    };
  }

  Future<List<OfertaModel>> fetchOfertasDisponiveis() async {
    await _buscarAmbos();
    return _cacheUltimaBusca?['disponiveis'] ?? [];
  }

  Future<List<OfertaModel>> fetchMinhasOfertas() async {
    // Como a tela chama os dois ao mesmo tempo, usamos o cache da primeira chamada
    if (_cacheUltimaBusca == null) await _buscarAmbos();
    final res = _cacheUltimaBusca?['minhas'] ?? [];
    _cacheUltimaBusca = null; // Limpa o cache para a próxima vez que a tela recarregar
    return res;
  }

  Future<void> criarOferta({required String startupId, required int quantity, required int purchasePriceCents}) async {
    await _functions.httpsCallable('createExchangeRequest').call({
      'startupId': startupId,
      'quantity': quantity,
      'purchasePriceCents': purchasePriceCents,
    });
  }

  Future<void> aceitarOferta({required String exchangeId, required String startupId}) async {
    await _functions.httpsCallable('acceptExchangeRequest').call({
      'exchangeId': exchangeId,
      'startupId': startupId,
    });
  }

  Future<void> cancelarOferta({required String exchangeId, required String startupId}) async {
    await _functions.httpsCallable('deleteExchangeRequest').call({
      'exchangeId': exchangeId,
      'startupId': startupId,
    });
  }

  Future<List<Map<String, dynamic>>> fetchMeusTokensParaVenda() async {
    try {
      final callable = _functions.httpsCallable('listMyInvestments');
      final result = await callable.call();
      final rawList = result.data['data'] as List? ?? [];

      return rawList.map((e) {
        final map = Map<String, dynamic>.from(e);
        return {
          'id': map['id'],
          'nome': map['nome'],
          'disponiveis': (map['disponiveis'] as num).toInt(),
          'precoBase': (map['precoBase'] as num).toDouble(),
        };
      }).toList();
    } catch (e) {
      return []; // Se der erro, retorna vazio para não quebrar a tela
    }
  }
}