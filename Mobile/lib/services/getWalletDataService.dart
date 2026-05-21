import 'package:cloud_functions/cloud_functions.dart';

class GetWalletDataService {
  // Configurando para a mesma região do seu exemplo anterior
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  Future<Map<String, dynamic>?> fetchWalletDetails() async {
    try {
      // ATENÇÃO: Substitua 'getWalletDetails' pelo nome exato da sua Cloud Function exportada no backend
      final callable = _functions.httpsCallable('getWalletDetails');

      final result = await callable.call();

      // Dependendo de como você estruturou o retorno no Node.js, os dados estarão em result.data
      final response = result.data as Map<dynamic, dynamic>;

      // Caso a sua função retorne os dados dentro de uma chave "data" (ex: { data: { patrimonio: ... } })
      // você usaria response["data"]. Se retornar o objeto direto, use o código abaixo:
      return Map<String, dynamic>.from(response);

    } catch (e) {
      print("Erro ao buscar dados da carteira via Callable: $e");
      return null;
    }
  }

  Future<bool> updateWallet(double valor) async {
    try {
      final callable = _functions.httpsCallable('updateWallet');

      await callable.call({
        "balanceChangeCents": valor,
      });

      return true; // Sucesso
    } catch (e) {
      print("Erro ao atualizar carteira: $e");
      return false; // Falha
    }
  }
}