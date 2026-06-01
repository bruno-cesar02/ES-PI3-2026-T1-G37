/* Bruno César Gonçalves Lima Mota
   RA: 24795502*/

import 'package:flutter/material.dart';
import '../../models/startup_model.dart';
import '../../services/StartupDetails_service.dart';
import '../../theme/app_colors.dart';
import 'modal_pergunta.dart';

class AbaPerguntas extends StatefulWidget {
  final Startup startup;
  final bool canSendPrivateQuestions;
  final StartupService service;
  final VoidCallback onRecarregar;

  const AbaPerguntas({super.key, required this.startup, required this.canSendPrivateQuestions,
    required this.service, required this.onRecarregar});

  @override
  State<AbaPerguntas> createState() => _AbaPerguntasState();
}

class _AbaPerguntasState extends State<AbaPerguntas> {
  String? _expandedId;
  final Set<String> _liked = {};

  @override
  Widget build(BuildContext context) {
    final perguntas = widget.startup.perguntas;
    final temPrivadas = perguntas.any((p) => p.visibility == QuestionVisibility.privada);

    return ListView(padding: const EdgeInsets.all(16), children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Text('${perguntas.length} ${perguntas.length == 1 ? "pergunta" : "perguntas"} da comunidade',
          style: const TextStyle(color: Color(0xFF999999), fontSize: 12))),

      if (temPrivadas) Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(children: const [
            Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primaryDark),
            SizedBox(width: 8),
            Expanded(child: Text(
              'Você está vendo perguntas exclusivas de investidores.',
              style: TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w500),
            )),
          ]),
        ),
      ),

      ...perguntas.map((p) {
        final expanded = _expandedId == p.id;
        final isPrivada = p.visibility == QuestionVisibility.privada;

        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              border: Border.all(color: isPrivada ? AppColors.primary.withOpacity(0.3) : AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(children: [
              GestureDetector(
                onTap: () => setState(() => _expandedId = expanded ? null : p.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(padding: const EdgeInsets.all(16),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (isPrivada) Padding(
                      padding: const EdgeInsets.only(right: 8, top: 2),
                      child: Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primary),
                    ),
                    Expanded(child: Text(p.pergunta, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4))),
                    const SizedBox(width: 8),
                    Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: expanded ? AppColors.primary : AppColors.iconInactive, size: 20),
                  ]))),
              if (expanded) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(12)),
                    child: Text(p.resposta, style: const TextStyle(color: Color(0xFF444444), fontSize: 13, height: 1.6))),
                  const SizedBox(height: 12),
                  Row(children: [
                    GestureDetector(
                      onTap: () => setState(() { _liked.contains(p.id) ? _liked.remove(p.id) : _liked.add(p.id); }),
                      child: Row(children: [
                        Icon(_liked.contains(p.id) ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, size: 14,
                          color: _liked.contains(p.id) ? AppColors.primary : const Color(0xFFAAAAAA)),
                        const SizedBox(width: 4),
                        Text('${p.likes + (_liked.contains(p.id) ? 1 : 0)}',
                          style: TextStyle(color: _liked.contains(p.id) ? AppColors.primary : const Color(0xFFAAAAAA), fontSize: 13)),
                      ])),
                    const SizedBox(width: 16),
                    const Row(children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFFAAAAAA)), SizedBox(width: 4),
                    ]),
                  ]),
                ])),
            ])));
      }),

      GestureDetector(
        onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => ModalPergunta(startupId: widget.startup.id, canSendPrivateQuestions: widget.canSendPrivateQuestions,
            service: widget.service, onEnviado: widget.onRecarregar)),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2,
            strokeAlign: BorderSide.strokeAlignInside), borderRadius: BorderRadius.circular(24)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 16), const SizedBox(width: 8),
            Text(widget.canSendPrivateQuestions ? 'Fazer uma pergunta pública ou privada' : 'Fazer uma pergunta',
              style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
          ]))),
      const SizedBox(height: 16),
    ]);
  }
}