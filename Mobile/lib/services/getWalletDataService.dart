import 'package:cloud_functions/cloud_functions.dart';

class GetWalletDataService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  Future<Map<String, dynamic>?> fetchWalletDetails() async {
    try {
      final callable = _functions.httpsCallable('getWalletDetails');
      final result = await callable.call();
      final response = result.data as Map<dynamic, dynamic>;

      return Map<String, dynamic>.from(response);
    } catch (e) {
      print("Erro ao buscar dados da carteira via Callable: $e");
      return null;
    }
  }

  Future<bool> updateWallet(double valorEmReais) async {
    try {
      final callable = _functions.httpsCallable('updateWallet');


      final int valorEmCentavos = (valorEmReais * 100).round();

      await callable.call({
        "balanceChangeCents": valorEmCentavos, // Enviando em centavos!
      });

      return true; // Sucesso
    } catch (e) {
      print("Erro ao atualizar carteira: $e");
      return false; // Falha
    }
  }
}