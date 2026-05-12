/* Bruno César Gonçalves Lima Mota
   RA: 24795502
   Modal para envio de perguntas públicas ou privadas. */

import 'package:flutter/material.dart';
import '../../services/StartupDetails_service.dart';
import '../../theme/app_colors.dart';

class ModalPergunta extends StatefulWidget {
  final String startupId;
  final bool canSendPrivateQuestions;
  final StartupService service;
  final VoidCallback onEnviado;

  const ModalPergunta({
    super.key,
    required this.startupId,
    required this.canSendPrivateQuestions,
    required this.service,
    required this.onEnviado,
  });

  @override
  State<ModalPergunta> createState() => _ModalPerguntaState();
}

class _ModalPerguntaState extends State<ModalPergunta> {
  final _controller = TextEditingController();
  bool _isPrivada = false;
  bool _enviando  = false;

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _enviarPergunta() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    setState(() => _enviando = true);
    try {
      await widget.service.createStartupQuestion(
        startupId: widget.startupId, text: texto,
        visibility: _isPrivada ? 'privada' : 'publica',
      );
      if (!mounted) return;
      Navigator.pop(context);
      widget.onEnviado();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Pergunta enviada com sucesso!'),
        backgroundColor: AppColors.positive, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao enviar pergunta: $e'),
        backgroundColor: AppColors.negative, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 20),
        const Text('Fazer uma pergunta', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(
          controller: _controller, maxLines: 3, enabled: !_enviando, textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Escreva sua pergunta para os fundadores...', hintStyle: const TextStyle(color: Color(0xFF999999)),
            filled: true, fillColor: const Color(0xFFF5F6F8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.canSendPrivateQuestions) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Icon(_isPrivada ? Icons.lock_outline_rounded : Icons.public_rounded, size: 18, color: _isPrivada ? AppColors.primaryDark : AppColors.positive),
              const SizedBox(width: 10),
              Expanded(child: Text(_isPrivada ? 'Pergunta privada' : 'Pergunta pública', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
              SizedBox(height: 28, child: Switch.adaptive(value: _isPrivada, activeColor: AppColors.primary, onChanged: _enviando ? null : (v) => setState(() => _isPrivada = v))),
            ]),
          ),
          const SizedBox(height: 4),
          Padding(padding: const EdgeInsets.only(left: 4), child: Text(
            _isPrivada ? 'Somente a startup verá esta pergunta.' : 'Todos os usuários poderão ver esta pergunta.',
            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
          )),
          const SizedBox(height: 16),
        ],
        GestureDetector(
          onTap: _enviando ? null : _enviarPergunta,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: _enviando ? null : const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              color: _enviando ? AppColors.primary.withOpacity(0.5) : null, borderRadius: BorderRadius.circular(24),
            ),
            child: Center(child: _enviando
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))
              : const Text('Enviar Pergunta', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }
}
