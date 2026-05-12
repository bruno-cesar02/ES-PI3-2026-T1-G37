/*Nicolas Carvalho Nogueira
* RA: 24801664
* */

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/firebase_options.dart';

class LogarService {
  static Future<bool> logar({
    required String email,
    required String senha,
}) async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'southamerica-east1').httpsCallable('loginUser');
      final resposta = await callable.call({
        'email' : email,
        'senha': senha,
        'apiKey': DefaultFirebaseOptions.currentPlatform.apiKey,
      });

      final customToken = resposta.data['data']['customToken'];

      await FirebaseAuth.instance.signInWithCustomToken(customToken);

      return true;

    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro desconhecido no servidor.');
    } catch (e) {
      throw Exception('Erro de conexão: Verifique sua internet.');
    }
  }
}