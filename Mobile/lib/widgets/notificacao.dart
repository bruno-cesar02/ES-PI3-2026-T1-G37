import 'package:flutter/material.dart';

/// Sistema de notificações do MesclaInvest.
///
/// Analogia: pensa num brinde numa festa. Em vez de cada convidado
/// fazer o seu próprio brinde do zero, tem um único "mestre de cerimônias"
/// (esse arquivo) que serve o brinde certo para cada ocasião:
/// - Verde com ✓ = sucesso
/// - Vermelho com ✗ = erro
/// - Azul com ℹ = informação
///
/// COMO USAR em qualquer gaveta ou tela:
///   Notificacao.sucesso(context, 'Cadastro realizado!');
///   Notificacao.erro(context, 'As senhas não coincidem.');
///   Notificacao.info(context, 'Verifique seu e-mail.');
class Notificacao {
  // ── Atalhos públicos ───────────────────────────────────────────

  static void sucesso(BuildContext context, String mensagem) {
    _mostrar(
      context,
      mensagem: mensagem,
      icone: Icons.check_circle_rounded,
      corFundo: const Color(0xFF1B4332),   // verde escuro
      corBarra: const Color(0xFF2D6A4F),
      corIcone: const Color(0xFF52B788),   // verde claro
    );
  }

  static void erro(BuildContext context, String mensagem) {
    _mostrar(
      context,
      mensagem: mensagem,
      icone: Icons.cancel_rounded,
      corFundo: const Color(0xFF3B0F0F),   // vermelho escuro
      corBarra: const Color(0xFF7B2D2D),
      corIcone: const Color(0xFFE57373),   // vermelho claro
    );
  }

  static void info(BuildContext context, String mensagem) {
    _mostrar(
      context,
      mensagem: mensagem,
      icone: Icons.info_rounded,
      corFundo: const Color(0xFF0D2137),   // azul escuro
      corBarra: const Color(0xFF1565C0),
      corIcone: const Color(0xFF64B5F6),   // azul claro
    );
  }

  // ── Motor interno ──────────────────────────────────────────────
  static void _mostrar(
      BuildContext context, {
        required String mensagem,
        required IconData icone,
        required Color corFundo,
        required Color corBarra,
        required Color corIcone,
      }) {
    // Garante que o overlay existe (funciona dentro de gavetas também)
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificacaoWidget(
        mensagem: mensagem,
        icone: icone,
        corFundo: corFundo,
        corBarra: corBarra,
        corIcone: corIcone,
        aoFechar: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}


// ════════════════════════════════════════════════════════════════
// Widget visual da notificação — não use diretamente,
// use sempre pelos métodos estáticos acima.
// ════════════════════════════════════════════════════════════════
class _NotificacaoWidget extends StatefulWidget {
  final String mensagem;
  final IconData icone;
  final Color corFundo;
  final Color corBarra;
  final Color corIcone;
  final VoidCallback aoFechar;

  const _NotificacaoWidget({
    required this.mensagem,
    required this.icone,
    required this.corFundo,
    required this.corBarra,
    required this.corIcone,
    required this.aoFechar,
  });

  @override
  State<_NotificacaoWidget> createState() => _NotificacaoWidgetState();
}

class _NotificacaoWidgetState extends State<_NotificacaoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;     // entra deslizando do topo
  late Animation<double> _barra;     // barra de progresso diminui

  static const _duracao = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _duracao);

    // Notificação desliza de cima para baixo ao aparecer
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      // Só usa os primeiros 20% da animação para entrar
      curve: const Interval(0.0, 0.20, curve: Curves.easeOut),
    ));

    // Barra de progresso vai de 1.0 (cheio) até 0.0 (vazio)
    _barra = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        // A barra só começa a diminuir depois que a notificação entrou
        curve: const Interval(0.20, 1.0, curve: Curves.linear),
      ),
    );

    _controller.forward().then((_) => widget.aoFechar());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            // Usuário pode fechar deslizando pra cima
            onVerticalDragUpdate: (d) {
              if (d.primaryDelta != null && d.primaryDelta! < -5) {
                widget.aoFechar();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: widget.corFundo,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.corIcone.withOpacity(0.30),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Conteúdo principal ────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                    child: Row(
                      children: [
                        // Ícone com fundo circular
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: widget.corIcone.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(widget.icone, color: widget.corIcone, size: 22),
                        ),

                        const SizedBox(width: 12),

                        // Texto da notificação
                        Expanded(
                          child: Text(
                            widget.mensagem,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),

                        // Botão X para fechar manualmente
                        GestureDetector(
                          onTap: widget.aoFechar,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.white.withOpacity(0.50),
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Barra de progresso no rodapé ─────────────
                  // Vai diminuindo enquanto a notificação está na tela
                  AnimatedBuilder(
                    animation: _barra,
                    builder: (_, __) => ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      child: LinearProgressIndicator(
                        value: _barra.value,
                        minHeight: 3,
                        backgroundColor: widget.corBarra.withOpacity(0.25),
                        valueColor: AlwaysStoppedAnimation(widget.corIcone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}