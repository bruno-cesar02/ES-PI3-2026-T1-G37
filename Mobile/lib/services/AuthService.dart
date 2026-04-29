/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'dart:convert';
import 'package:http/http.dart' as http;

/// AuthService — o "garçom" entre o Flutter e o Node.js.
///
/// Analogia: pense no Flutter como o cliente do restaurante,
/// o Node.js como a cozinha, e esse arquivo como o garçom.
/// O garçom (AuthService) leva o pedido (dados do cadastro)
/// para a cozinha (Node), que salva no estoque (Firebase).
///
/// CONFIGURAÇÃO:
/// Troque [_baseUrl] pelo endereço real do seu backend Node.js.
/// - Emulador Android: use 'http://10.0.2.2:3000'
/// - Dispositivo físico na mesma rede WiFi: use o IP da sua máquina
///   ex: 'http://192.168.0.10:3000'
class AuthService {
  // ⚠️ Troque pelo IP da sua máquina se estiver num celular físico
  static const String _baseUrl = 'http://10.0.2.2:3300';

  /// Envia os dados de cadastro para o Node.js.
  ///
  /// Retorna [true] se o cadastro funcionou.
  /// Lança uma [Exception] com a mensagem de erro se falhar.
  static Future<bool> cadastrar({
    required String nome,
    required String email,
    required String cpf,
    required String celular,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/cadastro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'cpf': cpf,
          'celular': celular,
          'senha': senha,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Cadastro criado com sucesso
        return true;
      } else {
        // Servidor respondeu com erro (ex: email já cadastrado)
        throw Exception(data['mensagem'] ?? 'Erro ao cadastrar');
      }
    } catch (e) {
      // Sem internet, servidor fora do ar, etc.
      rethrow;
    }
  }
}