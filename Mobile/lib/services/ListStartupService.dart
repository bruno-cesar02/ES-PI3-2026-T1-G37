/*
Nome: Otávio Augusto Antunes Marquez
RA:24025832
*/

import 'package:cloud_functions/cloud_functions.dart';


class ListStartupService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  Future<List<Map<String, dynamic>>> listStartups({String? stage, String? search}) async {
    try {
      final callable = _functions.httpsCallable('listStartups');


      final result = await callable.call({
        "stage": stage,
        "search": search
      });

      final response = result.data as Map<dynamic, dynamic>;

      final List<dynamic> listData = response["data"] ?? [];

      final List<Map<String, dynamic>> startups = listData.map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      return startups;

    } catch (e) {
      print("Erro ao listar startups: $e");
      return [];
    }
  }
}