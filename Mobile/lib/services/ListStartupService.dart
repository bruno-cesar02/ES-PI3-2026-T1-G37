import 'package:cloud_functions/cloud_functions.dart';


class ListStartupService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  Future<List<Map<String, dynamic>>> listStartups({dynamic stage, dynamic search}) async {
    try {
      final callable = _functions.httpsCallable('listStartups');

      final result = await callable.call({
        "stage": stage,
        "search": search
      });

      // 1. O Firebase retorna um Map<String, dynamic> que contém a chave "data"
      final response = result.data as Map<dynamic, dynamic>;

      // 2. Extraímos a lista como List<dynamic> primeiro
      final List<dynamic> listData = response["data"] ?? [];

      // 3. CONVERSÃO CRUCIAL: Transforma cada item da lista em Map<String, dynamic>
      final List<Map<String, dynamic>> startups = listData.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      print("Startups carregadas: ${startups.length}");
      print(startups);
      return startups;

    } catch (e) {
      print("Erro ao listar startups: $e");
      // Retorna lista vazia em caso de erro para não quebrar a UI
      return [];
    }
  }
}