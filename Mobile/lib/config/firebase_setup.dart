import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseSetup {
  // 🎛️ A SUA CHAVE MESTRA:
  // true = usa o Emulador no seu PC
  // false = usa o Firebase real na nuvem do Google
  static const bool usarEmulador = true;

  static Future<void> inicializar() async {
    // Inicializa o Firebase com as chaves (falsas para emulador, ou reais se for nuvem)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDummyKeyForLocalEmulatorTesting12',
        appId: '1:123456789012:android:1234567890abcdef',
        messagingSenderId: '123456789012',
        projectId: 'pi3-g37',
      ),
    );

    // Se a chave mestra estiver ligada, ele redireciona a rota para o emulador
    if (usarEmulador) {
      await _conectarEmulador();
    }
  }

  static Future<void> _conectarEmulador() async {
    try {
      String host = 'localhost';
      // Descobre automaticamente se está no emulador do Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        host = '10.0.2.2';
      }

      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);

      print('✅ MODO DEV: Conectado ao Emulador Local!');
    } catch (e) {
      print('❌ Erro ao conectar no emulador: $e');
    }
  }
}