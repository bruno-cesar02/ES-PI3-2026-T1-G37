/*Nicolas Carvalho Nogueira
* RA 24801664*/

import 'package:firebase_auth/firebase_auth.dart';

class ResultadoLogin {
  final bool sucesso;
  final bool requer2FA;
  final MultiFactorResolver? resolver;
  final String? erro;

  ResultadoLogin({
    required this.sucesso,
    this.requer2FA = false,
    this.resolver,
    this.erro,
  });
}

class LogarService {
  static Future<ResultadoLogin> logar({
    required String email,
    required String senha,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return ResultadoLogin(sucesso: true);

    } on FirebaseAuthMultiFactorException catch (e) {
      return ResultadoLogin(
        sucesso: false,
        requer2FA: true,
        resolver: e.resolver,
      );
    } on FirebaseAuthException catch (e) {
      String mensagemErro = 'Erro ao fazer login.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        mensagemErro = 'E-mail ou senha inválidos.';
      } else if (e.code == 'too-many-requests') {
        mensagemErro = 'Muitas tentativas falhas. Tente novamente mais tarde.';
      }
      return ResultadoLogin(sucesso: false, erro: mensagemErro);
    } catch (e) {
      return ResultadoLogin(sucesso: false, erro: 'Erro inesperado: $e');
    }
  }
}