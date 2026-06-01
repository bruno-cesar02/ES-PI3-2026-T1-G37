//Nicolas Carvalho Nogueira
//RA 24801664

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/screens/tela_logada_screen.dart'; // <-- ADICIONE ESTA LINHA
import 'botao_primario.dart';
import 'campo_texto.dart';
import 'notificacao.dart';

class GavetaMfa extends StatefulWidget {
  final MultiFactorResolver resolver;

  const GavetaMfa({super.key, required this.resolver});

  @override
  State<GavetaMfa> createState() => _GavetaMfaState();
}

class _GavetaMfaState extends State<GavetaMfa> {
  final _codigoController = TextEditingController();
  bool _processando = false;
  bool _enviandoSms = true;
  String? _verificationId;
  String _telefoneMascarado = '';

  @override
  void initState() {
    super.initState();
    _dispararSms();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _dispararSms() async {
    if (widget.resolver.hints.isEmpty) {
      if (mounted) Notificacao.erro(context, 'Nenhum telefone cadastrado.');
      return;
    }

    final phoneHint = widget.resolver.hints.first as PhoneMultiFactorInfo;

    setState(() {
      _telefoneMascarado = phoneHint.phoneNumber;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      multiFactorSession: widget.resolver.session,
      multiFactorInfo: phoneHint,
      verificationCompleted: (_) {},
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          Notificacao.erro(context, 'Erro ao enviar SMS: ${e.message}');
          setState(() => _enviandoSms = false);
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _enviandoSms = false;
          });
          Notificacao.sucesso(context, 'SMS enviado com sucesso!');
        }
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> _validarCodigo() async {
    if (_codigoController.text.trim().isEmpty) {
      Notificacao.erro(context, 'Por favor, insira o código.');
      return;
    }

    if (_verificationId == null) {
      Notificacao.erro(context, 'Aguarde o envio do SMS.');
      return;
    }

    setState(() => _processando = true);

    try {
      final credencial = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codigoController.text.trim(),
      );

      final assertion = PhoneMultiFactorGenerator.getAssertion(credencial);
      await widget.resolver.resolveSignIn(assertion);

      if (mounted) {
        // Sucesso! Fecha todas as telas anteriores (como a de login)
        // e abre a TelaLogadaScreen diretamente.
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TelaLogadaScreen()),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) Notificacao.erro(context, 'Código inválido ou expirado.');
    } catch (e) {
      if (mounted) Notificacao.erro(context, 'Erro inesperado: $e');
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // Removemos a altura fixa (0.82) para evitar o estouro de pixels
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2A4A).withOpacity(0.95), // Mesma cor do login
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- O SEGREDO: A gaveta só ocupa o necessário
        children: [
          // Puxador da gaveta (mesmo padrão)
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Conteúdo centralizado e com padding consistente
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Verificação',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  if (_enviandoSms) ...[
                    const CircularProgressIndicator(color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    const Text('Validando sua identidade...', style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 24),
                  ] else ...[
                    Text(
                      'Enviamos um código para $_telefoneMascarado',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    CampoTexto(
                      label: 'Código de 6 dígitos',
                      controller: _codigoController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    _processando
                        ? const CircularProgressIndicator(color: Colors.blueAccent)
                        : BotaoPrimario(
                      texto: 'Validar e Entrar',
                      isPrimary: true,
                      onPressed: _validarCodigo,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}