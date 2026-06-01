//Nicolas Carvalho Nogueira
//RA 24801664

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'notificacao.dart';

class GavetaAtivarMfa extends StatefulWidget {
  final String telefoneSalvo;

  const GavetaAtivarMfa({super.key, required this.telefoneSalvo});

  @override
  State<GavetaAtivarMfa> createState() => _GavetaAtivarMfaState();
}

class _GavetaAtivarMfaState extends State<GavetaAtivarMfa> {
  final _codigoController = TextEditingController();

  bool _carregando = false;
  int _etapa = 1;
  String? _verificationId;
  late String _telefoneFormatado;

  @override
  void initState() {
    super.initState();
    String numeros = widget.telefoneSalvo.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length == 10 || numeros.length == 11) {
      _telefoneFormatado = '+55$numeros';
    } else {
      _telefoneFormatado = widget.telefoneSalvo.startsWith('+') ? widget.telefoneSalvo : '+$numeros';
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _enviarSms() async {
    setState(() => _carregando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não está logado.');

      final session = await user.multiFactor.getSession();

      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: _telefoneFormatado,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            Notificacao.erro(context, 'Erro ao enviar SMS: ${e.message}');
            setState(() => _carregando = false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _etapa = 2;
              _carregando = false;
            });
            Notificacao.sucesso(context, 'SMS enviado! Verifique seu celular.');
          }
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) {
        Notificacao.erro(context, 'Erro: $e');
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _confirmarCadastroMfa() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty || _verificationId == null) {
      Notificacao.erro(context, 'Digite o código recebido.');
      return;
    }

    setState(() => _carregando = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não logado.');

      final credencial = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: codigo,
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credencial);
      await user.multiFactor.enroll(assertion, displayName: 'Celular Principal');

      if (mounted) {
        Notificacao.sucesso(context, 'Autenticação de 2 Fatores ATIVADA!');
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Notificacao.erro(context, 'Código inválido. Tente novamente.');
    } catch (e) {
      if (mounted) Notificacao.erro(context, 'Erro ao ativar 2FA: $e');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82 + bottomInset,
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A4A).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 60, height: 5, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, bottomInset + 16),
              child: Column(
                children: [
                  Text(
                    _etapa == 1 ? 'Ativar Segurança Extra' : 'Confirmar Código',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _etapa == 1
                        ? 'Vincularemos o seu dispositivo usando o celular cadastrado no seu perfil:\n\n${widget.telefoneSalvo}'
                        : 'Digite o código de 6 dígitos que enviamos via SMS para confirmar o vínculo.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  if (_etapa == 2)
                    CampoTexto(label: 'Código de 6 dígitos', controller: _codigoController, keyboardType: TextInputType.number),

                  const SizedBox(height: 32),
                  _carregando
                      ? const CircularProgressIndicator(color: Color(0xFF1E90FF))
                      : BotaoPrimario(
                    texto: _etapa == 1 ? 'Receber código por SMS' : 'Ativar 2FA',
                    isPrimary: true,
                    onPressed: _etapa == 1 ? _enviarSms : _confirmarCadastroMfa,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}