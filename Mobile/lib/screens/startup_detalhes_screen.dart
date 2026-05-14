/* Bruno César Gonçalves Lima Mota — RA: 24795502
   Tela de detalhes da startup — orquestra header, abas e dados do Firebase. */

import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../services/StartupDetails_service.dart';
import '../theme/app_colors.dart';
import '../widgets/startup_detalhes/detalhes_helpers.dart';
import '../widgets/startup_detalhes/aba_geral.dart';
import '../widgets/startup_detalhes/aba_financeiro.dart';
import '../widgets/startup_detalhes/aba_socios.dart';
import '../widgets/startup_detalhes/aba_perguntas.dart';
import '../widgets/startup_detalhes/aba_midia.dart';

class StartupDetailsPage extends StatefulWidget {
  final String startupId;
  const StartupDetailsPage({super.key, required this.startupId});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage>
    with SingleTickerProviderStateMixin {

  late final TabController _tabController;

  Startup?  _startup;
  bool      _loading = false;
  String?   _error;
  bool         _isInvestor              = false;
  bool         _canTradeTokens          = false;
  bool         _canSendPrivateQuestions = false;
  List<String> _demoVideos             = [];
  String?      _pitchDeckUrl;
  String?      _coverImageUrl;
  List<String> _tags                   = [];

  static const _tabLabels = ['Geral', 'Financeiro', 'Sócios', 'Perguntas', 'Mídia'];
  static const _tabIcons  = [
    Icons.info_outline_rounded, Icons.attach_money_rounded,
    Icons.people_outline_rounded, Icons.chat_bubble_outline_rounded,
    Icons.play_circle_outline_rounded,
  ];

  @override
  void initState() { super.initState(); _tabController = TabController(length: 5, vsync: this); _buscarDados(); }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  Future<void> _buscarDados() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await StartupService.instance.getStartupDetails(widget.startupId);
      if (mounted) setState(() {
        _startup = r.startup; _isInvestor = r.isInvestor; _canTradeTokens = r.canTradeTokens;
        _canSendPrivateQuestions = r.canSendPrivateQuestions; _demoVideos = r.demoVideos;
        _pitchDeckUrl = r.pitchDeckUrl; _coverImageUrl = r.coverImageUrl; _tags = r.tags;
      });
    } catch (e) { if (mounted) setState(() => _error = e.toString()); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  Color _stageColor(String setor) {
    if (setor.contains('Operação')) return AppColors.primary;
    if (setor.contains('Expansão')) return AppColors.warning;
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,
        body: Column(children: [_buildHeader(), _buildWhiteSheet()]));
  }

  Widget _buildHeader() {
    return SafeArea(bottom: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                  child: Container(width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20))),
              const SizedBox(height: 12),
              if (_loading) const HeaderSkeleton()
              else if (_error != null) HeaderErro(onRetry: _buscarDados)
              else if (_startup != null) _buildHeaderContent(_startup!),
            ])));
  }

  Widget _buildHeaderContent(Startup s) {
    final statusText = s.status.startsWith('*') ? s.status.substring(1) : s.status;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 68, height: 68,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, Color(0xFF1A3A8F)]),
                borderRadius: BorderRadius.circular(16)),
            child: (_coverImageUrl != null && _coverImageUrl!.isNotEmpty)
                ? Image.network(
              _coverImageUrl!,
              width: 68, height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Text(buildInitials(s.nome),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              ),
            )
                : Center(child: Text(buildInitials(s.nome),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 16),
        Expanded(child: Padding(padding: const EdgeInsets.only(top: 2),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.nome, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2)),
              const SizedBox(height: 2),
              Row(children: [
                Text(statusText, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('•', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13))),
                Text(s.variacao, style: TextStyle(color: s.variacaoPositiva ? AppColors.positive : AppColors.negative, fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(color: _stageColor(s.setor), borderRadius: BorderRadius.circular(6)),
                    child: Text(s.setor, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(6)),
                    child: Text('#${s.codigo}', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11))),
              ]),
            ]))),
      ]),
      if (s.descricaoBreve.isNotEmpty) ...[const SizedBox(height: 12),
        Text(s.descricaoBreve, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13, height: 1.55, fontWeight: FontWeight.w300))],
      if (_tags.isNotEmpty) ...[const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: _tags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(border: Border.all(color: Colors.white.withOpacity(0.2)), borderRadius: BorderRadius.circular(999)),
            child: Text('#$tag', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11)))).toList())],
    ]);
  }

  Widget _buildWhiteSheet() {
    return Expanded(child: Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: _loading ? const ContentSkeleton()
            : _error != null ? TelaErro(mensagem: _error!, onRetry: _buscarDados)
            : _startup == null ? const SizedBox.shrink()
            : Column(children: [
          Padding(padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(2)))),
          _buildTabBar(),
          Expanded(child: TabBarView(controller: _tabController, children: [
            AbaGeral(startup: _startup!),
            AbaFinanceiro(startup: _startup!, isInvestor: _isInvestor, canTradeTokens: _canTradeTokens),
            AbaSocios(startup: _startup!),
            AbaPerguntas(startup: _startup!, canSendPrivateQuestions: _canSendPrivateQuestions,
                service: StartupService.instance, onRecarregar: _buscarDados),
            AbaMidia(startup: _startup!, demoVideos: _demoVideos, pitchDeckUrl: _pitchDeckUrl),
          ])),
        ])));
  }

  Widget _buildTabBar() {
    return Container(
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1))),
        child: TabBar(controller: _tabController, isScrollable: false, padding: EdgeInsets.zero, labelPadding: EdgeInsets.zero,
            indicatorColor: AppColors.primary, indicatorWeight: 2, indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppColors.primary, unselectedLabelColor: const Color(0xFFAAAAAA), dividerColor: Colors.transparent,
            tabs: List.generate(5, (i) => Tab(height: 52,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_tabIcons[i], size: 15), const SizedBox(height: 3),
                  Text(_tabLabels[i], style: const TextStyle(fontSize: 11))])))));
  }
}