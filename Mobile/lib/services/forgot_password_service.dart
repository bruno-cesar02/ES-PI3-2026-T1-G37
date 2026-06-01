/* Eduardo Neves de Aguiar 
  RA:24026029*/
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordService {
  /// Envia e-mail de recuperação de senha usando o Firebase Auth.
  static Future<bool> enviarEmailRecuperacao({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://pi3-g37.web.app',
          handleCodeInApp: false,
        ),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return true; // Por segurança retorna sucesso
      }
      throw Exception(e.message ?? 'Erro ao enviar e-mail.');
    } catch (e) {
      throw Exception('Erro de conexão: Verifique sua internet.');
    }
  }
}