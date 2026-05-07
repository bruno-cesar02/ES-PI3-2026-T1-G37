import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


import '../firebase_options.dart';

class FirebaseSetup {

  static const bool usarEmulador = false; // true para usar o emulador

  static Future<void> inicializar() async {

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (usarEmulador) {
      await _conectarEmulador();
    }
  }

  static Future<void> _conectarEmulador() async {
    try {
      String host = 'localhost';
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        host = '10.0.2.2';
      }

      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);

      FirebaseFunctions.instanceFor(region: 'southamerica-east1')
          .useFunctionsEmulator(host, 5001);

      print('✅ MODO DEV: Conectado ao Emulador Local!');
    } catch (e) {
      print('❌ Erro ao conectar no emulador: $e');
    }
  }
}