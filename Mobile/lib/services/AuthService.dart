/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'package:cloud_functions/cloud_functions.dart';

class AuthService {
  /// Envia os dados de cadastro direto para a Cloud Function do Firebase.
  ///
  /// Retorna [true] se o cadastro funcionou.
  /// Lança uma [Exception] com a mensagem de erro que veio do backend se falhar.
  static Future<bool> cadastrar({
    required String nome,
    required String email,
    required String cpf,
    required String celular,
    required String senha,
  }) async {
    try {
      // Chama a função pelo nome exato que está lá no backend TypeScript
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('createUser');

      // Manda o pacote de dados. O SDK do Firebase já sabe o IP e a porta corretos
      // por causa daquela configuração do Emulador no main.dart!
      await callable.call({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'celular': celular,
        'senha': senha,
      });

      // Se passou da linha de cima sem dar erro, é porque retornou status 200 (Sucesso)
      return true;

    } on FirebaseFunctionsException catch (e) {
      // O Firebase captura as mensagens de erro exatas do backend (ex: "Este e-mail já está em uso.")
      throw Exception(e.message ?? 'Erro desconhecido no servidor.');
    } catch (e) {
      // Caso caia a internet do celular
      throw Exception('Erro de conexão: Verifique sua internet.');
    }
  }
}