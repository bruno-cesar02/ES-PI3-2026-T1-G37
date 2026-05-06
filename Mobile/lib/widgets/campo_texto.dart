/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════
// CAMPO GENÉRICO — use para Nome, Email, CPF, Celular, etc.
// ════════════════════════════════════════════════════════════════

/// Campo de texto reutilizável do MesclaInvest.
///
/// Para campos de senha, use [CampoSenha] que tem olho + requisitos.
class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFFD9D9D9).withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
// CAMPO DE SENHA — com olho para mostrar/esconder
// e requisitos que aparecem quando o campo está em foco.
//
// Analogia: pensa num cofre de hotel. Você digita a combinação
// (a senha), pode apertar um botão para ver os números que digitou
// (o olho), e tem um guia colado na porta dizendo quais
// combinações são válidas (os requisitos).
// ════════════════════════════════════════════════════════════════

/// Campo de senha com:
/// - Ícone de olho para mostrar/esconder
/// - Requisitos visuais que aparecem ao focar no campo
///
/// [label]: placeholder do campo (ex: 'Senha', 'Confirmar senha')
/// [controller]: captura o que o usuário digita
/// [mostrarRequisitos]: true = exibe os requisitos ao focar (use só no campo principal)
class CampoSenha extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool mostrarRequisitos;

  const CampoSenha({
    super.key,
    required this.label,
    required this.controller,
    this.mostrarRequisitos = false,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _escondido = true;    // começa escondendo a senha
  bool _emFoco = false;      // controla quando mostrar os requisitos
  final _foco = FocusNode();

  // ── Regras de validação ─────────────────────────────────────────
  // Alinhadas com o Firebase Auth + boas práticas de segurança.
  // O Firebase exige mínimo 6 chars, mas pedimos 8 para mais segurança.
  bool get _temMinimo8    => widget.controller.text.length >= 8;
  bool get _temMaiuscula  => widget.controller.text.contains(RegExp(r'[A-Z]'));
  bool get _temMinuscula  => widget.controller.text.contains(RegExp(r'[a-z]'));
  bool get _temNumero     => widget.controller.text.contains(RegExp(r'[0-9]'));
  bool get _temSimbolo    => widget.controller.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));

  @override
  void initState() {
    super.initState();

    // Reativa o rebuild quando o foco entra/sai do campo
    _foco.addListener(() {
      setState(() => _emFoco = _foco.hasFocus);
    });

    // Reativa o rebuild a cada caractere digitado (para atualizar os requisitos)
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Campo de texto ──────────────────────────────────────
        TextField(
          controller: widget.controller,
          focusNode: _foco,
          obscureText: _escondido,
          keyboardType: TextInputType.visiblePassword,
          style: const TextStyle(color: Colors.white70),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFFD9D9D9).withOpacity(0.25),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ),
            // Ícone de olho no lado direito
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  _escondido
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.white38,
                  size: 22,
                ),
                onPressed: () => setState(() => _escondido = !_escondido),
              ),
            ),
          ),
        ),

        // ── Requisitos — aparecem só quando o campo está em foco ──
        // AnimatedSize faz a caixinha crescer/encolher suavemente
        if (widget.mostrarRequisitos)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: _emFoco
                ? Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Requisitos da senha:',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Requisito(ok: _temMinimo8,   texto: 'Mínimo 8 caracteres'),
                  _Requisito(ok: _temMaiuscula, texto: 'Uma letra maiúscula (A-Z)'),
                  _Requisito(ok: _temMinuscula, texto: 'Uma letra minúscula (a-z)'),
                  _Requisito(ok: _temNumero,    texto: 'Um número (0-9)'),
                  _Requisito(ok: _temSimbolo,   texto: 'Um símbolo (!@#\$%&*)'),
                ],
              ),
            )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}


// ── Item individual de requisito ────────────────────────────────
// Fica verde com ✓ quando o requisito é atendido,
// cinza com • quando ainda não foi.
class _Requisito extends StatelessWidget {
  final bool ok;
  final String texto;

  const _Requisito({required this.ok, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              ok ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(ok),
              size: 16,
              color: ok ? const Color(0xFF52B788) : Colors.white30,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            texto,
            style: TextStyle(
              color: ok ? const Color(0xFF52B788) : Colors.white54,
              fontSize: 13,
              fontWeight: ok ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}