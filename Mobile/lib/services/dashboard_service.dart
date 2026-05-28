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
        // Tenta buscar o nome salvo no documento do usuário no Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return doc.data()!['nome'] ?? user.displayName ?? 'Investidor';
        }
        return user.displayName ?? 'Investidor';
      }
      return 'Investidor';
    } catch (e) {
      return 'Investidor'; // Fallback de segurança em caso de erro
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