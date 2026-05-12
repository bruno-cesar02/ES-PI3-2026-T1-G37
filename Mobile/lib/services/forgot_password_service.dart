/* Seu Nome - RA: XXXXXXXX */
import 'package:cloud_functions/cloud_functions.dart';

class ForgotPasswordService {

  /// Verifica se o e-mail existe no banco
  static Future<bool> verificarEmail({required String email}) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('checkEmail');
      await callable.call({'email': email});
      return true;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro desconhecido.');
    } catch (e) {
      throw Exception('Erro de conexão: Verifique sua internet.');
    }
  }

  /// Altera a senha do usuário
  static Future<bool> alterarSenha({
    required String email,
    required String novaSenha,
  }) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .httpsCallable('resetPassword');
      await callable.call({'email': email, 'novaSenha': novaSenha});
      return true;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro desconhecido.');
    } catch (e) {
      throw Exception('Erro de conexão: Verifique sua internet.');
    }
  }
}