import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Busca o nome do usuário logado (Auth + Firestore fallback)
  Future<String> fetchUserName() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        // 1. Tenta pegar primeiro o nome direto do perfil de autenticação
        if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
          return user.displayName!;
        }

        // 2. Se não tiver no Auth, vai buscar no Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          // Tenta ler 'nome', se for nulo tenta 'name', se for nulo usa o padrão
          return data['nome'] ?? data['name'] ?? 'parou aqui';
        }
      }

      // Se o usuário estiver nulo no Firebase Auth por algum motivo
      print("Aviso: _auth.currentUser retornou nulo.");
      return 'ta nulo';

    } catch (e) {
      // Se der erro de permissão (Missing or insufficient permissions) vai aparecer aqui
      print("Erro ao buscar nome do usuário no banco: $e");
      return 'o erro ao buscar nome do usuário';
    }
  }

  // Busca o resumo da carteira e a linha do tempo geral
  Future<Map<String, dynamic>> fetchGeneralDashboard(String range) async {
    final result = await _functions.httpsCallable('getUserDashboardData').call({
      'range': range,
    });
    return Map<String, dynamic>.from(result.data);
  }

  // Busca o histórico individual de uma startup específica
  Future<Map<String, dynamic>> fetchStartupHistory(String startupId, String range) async {
    final result = await _functions.httpsCallable('getStartupPriceHistory').call({
      'startupId': startupId,
      'range': range,
    });
    return Map<String, dynamic>.from(result.data);
  }
}