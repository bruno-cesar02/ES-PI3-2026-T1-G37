import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../services/startup_service.dart';

// ═══════════════════════════════════════════════════════════════════════════
// DESIGN SYSTEM
// ═══════════════════════════════════════════════════════════════════════════
const _bgDark        = Color(0xFF020C14);
const _primaryBlue   = Color(0xFF386BF6);
const _primaryDark   = Color(0xFF2558D4);
const _green         = Color(0xFF00AE51);
const _red           = Color(0xFFEF4444);
const _amber         = Color(0xFFF59E0B);
const _purple        = Color(0xFFA855F7);
const _textPrimary   = Color(0xFF020C14);
const _textSecondary = Color(0xFF555555);
const _cardBg        = Color(0xFFFAFAFA);
const _cardBorder    = Color(0xFFF0F0F0);
const _iconInactive  = Color(0xFF9DB2CE);

// ═══════════════════════════════════════════════════════════════════════════
// STARTUP DETAILS PAGE
// ═══════════════════════════════════════════════════════════════════════════
class StartupDetailsPage extends StatefulWidget {
  final String startupId;
  const StartupDetailsPage({super.key, required this.startupId});

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage>
    with SingleTickerProviderStateMixin {

  // ── Controlador das abas ─────────────────────────────────────────────────
  late final TabController _tabController;

  // ── Estado da página ─────────────────────────────────────────────────────
  Startup?  _startup;
  bool      _loading = false;
  String?   _error;

  // ── Dados extras do Firebase ──────────────────────────────────────────────
  bool         _isInvestor              = false;
  bool         _canTradeTokens          = false;
  bool         _canSendPrivateQuestions = false;
  List<String> _demoVideos             = [];
  String?      _pitchDeckUrl;
  String?      _coverImageUrl;
  List<String> _tags                   = [];

  // ── Abas ─────────────────────────────────────────────────────────────────
  static const _tabLabels = ['Geral', 'Financeiro', 'Sócios', 'Perguntas', 'Mídia'];
  static const _tabIcons  = [
    Icons.info_outline_rounded,
    Icons.attach_money_rounded,
    Icons.people_outline_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.play_circle_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _buscarDados();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Busca no Firebase ─────────────────────────────────────────────────────
  Future<void> _buscarDados() async {
    setState(() { _loading = true; _error = null; });
    try {
      final r = await StartupService.instance.getStartupDetails(widget.startupId);
      if (mounted) setState(() {
        _startup                  = r.startup;
        _isInvestor               = r.isInvestor;
        _canTradeTokens           = r.canTradeTokens;
        _canSendPrivateQuestions  = r.canSendPrivateQuestions;
        _demoVideos               = r.demoVideos;
        _pitchDeckUrl             = r.pitchDeckUrl;
        _coverImageUrl            = r.coverImageUrl;
        _tags                     = r.tags;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Badge color por stage ─────────────────────────────────────────────────
  Color _stageColor(String setor) {
    if (setor.contains('Operação')) return _primaryBlue;
    if (setor.contains('Expansão')) return _amber;
    return _purple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Column(children: [
        _buildHeader(),
        _buildWhiteSheet(),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // [2] HEADER ESCURO
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // [2.1] Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 20),
            ),
          ),

          const SizedBox(height: 12),

          if (_loading)
            const _HeaderSkeleton()
          else if (_error != null)
            _HeaderErro(onRetry: _buscarDados)
          else if (_startup != null)
              _buildHeaderContent(_startup!),
        ]),
      ),
    );
  }

  Widget _buildHeaderContent(Startup s) {
    final statusText = s.status.startsWith('*') ? s.status.substring(1) : s.status;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // [2.2] Row: Avatar + Info
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Avatar
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_primaryBlue, Color(0xFF1A3A8F)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: Text(
            _initials(s.nome),
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          )),
        ),

        const SizedBox(width: 16),

        // Info column
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Nome
            Text(s.nome, style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2,
            )),

            const SizedBox(height: 2),

            // Status • variação
            Row(children: [
              Text(statusText, style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 13,
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text('•', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
              ),
              Text(s.variacao, style: TextStyle(
                color: s.variacaoPositiva ? _green : _red,
                fontSize: 13, fontWeight: FontWeight.w700,
              )),
            ]),

            const SizedBox(height: 8),

            // Badges: stage + código
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: _stageColor(s.setor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(s.setor, style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                )),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('#${s.codigo}', style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 11,
                )),
              ),
            ]),
          ]),
        )),
      ]),

      // [2.3] Descrição breve
      if (s.descricaoBreve.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text(s.descricaoBreve, style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 13, height: 1.55, fontWeight: FontWeight.w300,
        )),
      ],

      // [2.4] Hashtags
      if (_tags.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          ...(_tags.isNotEmpty ? _tags : [s.setor, 'tokens', 'investimento']).map((tag) =>
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('#$tag', style: TextStyle(
                  color: Colors.white.withOpacity(0.55), fontSize: 11,
                )),
              ),
          ),
        ]),
      ],
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // [3] WHITE BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildWhiteSheet() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: _loading
            ? const _ContentSkeleton()
            : _error != null
            ? _TelaErro(mensagem: _error!, onRetry: _buscarDados)
            : _startup == null
            ? const SizedBox.shrink()
            : Column(children: [

          // [3.1] Drag pill
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // [3.2] Tab bar
          _buildTabBar(),

          // [3.3] Conteúdo
          Expanded(child: TabBarView(
            controller: _tabController,
            children: [
              _AbaGeral(startup: _startup!),
              _AbaFinanceiro(
                startup: _startup!,
                isInvestor: _isInvestor,
                canTradeTokens: _canTradeTokens,
              ),
              _AbaSocios(startup: _startup!),
              _AbaPerguntas(
                startup: _startup!,
                canSendPrivateQuestions: _canSendPrivateQuestions,
                service: StartupService.instance,
              ),
              _AbaMidia(
                startup: _startup!,
                demoVideos: _demoVideos,
                pitchDeckUrl: _pitchDeckUrl,
              ),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        indicatorColor: _primaryBlue,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: _primaryBlue,
        unselectedLabelColor: const Color(0xFFAAAAAA),
        dividerColor: Colors.transparent,
        tabs: List.generate(5, (i) => Tab(
          height: 52,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_tabIcons[i], size: 15),
            const SizedBox(height: 3),
            Text(_tabLabels[i], style: const TextStyle(fontSize: 11)),
          ]),
        )),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABA: GERAL
// ═══════════════════════════════════════════════════════════════════════════
class _AbaGeral extends StatelessWidget {
  final Startup startup;
  const _AbaGeral({required this.startup});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Seções textuais
        ...startup.geral.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _Card(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.titulo, style: const TextStyle(
                color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 8),
              Text(s.conteudo, style: const TextStyle(
                color: _textSecondary, fontSize: 13, height: 1.6,
              )),
            ],
          )),
        )),

        if (startup.geral.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Card(child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Informações em breve.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13)),
              ),
            )),
          ),

        // Card preço do token (dark)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [_bgDark, Color(0xFF0F2050)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Preço do Token', style: TextStyle(
              color: Colors.white.withOpacity(0.5), fontSize: 12,
            )),
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(startup.tokenPrice, style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700,
              )),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(startup.variacao, style: TextStyle(
                  color: startup.variacaoPositiva ? _green : _red,
                  fontSize: 15, fontWeight: FontWeight.w700,
                )),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABA: FINANCEIRO
// ═══════════════════════════════════════════════════════════════════════════
class _AbaFinanceiro extends StatelessWidget {
  final Startup startup;
  final bool isInvestor;
  final bool canTradeTokens;

  const _AbaFinanceiro({
    required this.startup,
    required this.isInvestor,
    required this.canTradeTokens,
  });

  @override
  Widget build(BuildContext context) {
    // Tenta parsear cpv como número para a barra de progresso
    final cpvNum = double.tryParse(
        startup.cpv.replaceAll('%', '').replaceAll(',', '.').trim()
    ) ?? 0;
    final cpvFraction = (cpvNum / 100).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Grid 2 colunas — 4 cards
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _FinCard(label: 'Capital Aportado', valor: startup.capitalAportado, sub: 'Simulado'),
            _FinCard(label: 'Tokens Emitidos',  valor: _formatTokens(startup.tokensEmitidos), sub: 'Total'),
            _FinCard(label: 'Previsão Receita', valor: startup.previsaoReceita, sub: '2026'),
            _FinCard(label: 'Margem Bruta',     valor: startup.margemBrutaAlvo, sub: 'Alvo'),
          ],
        ),

        const SizedBox(height: 12),

        // Card CPV com progress bar
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('CPV', style: TextStyle(
              color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
            )),
            Text(startup.cpv, style: const TextStyle(
              color: _primaryBlue, fontSize: 14, fontWeight: FontWeight.w700,
            )),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: cpvFraction,
              minHeight: 6,
              backgroundColor: _cardBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryBlue),
            ),
          ),
        ])),

        // Card investidor
        if (isInvestor) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.08),
              border: Border.all(color: _green.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: _green, size: 20),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Você é investidor desta startup', style: TextStyle(
                  color: _green, fontSize: 14, fontWeight: FontWeight.w700,
                )),
              ]),
            ]),
          ),
        ],

        const SizedBox(height: 12),

        // Botão principal
        GestureDetector(
          onTap: () => _mostrarModal(context),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [_primaryBlue, _primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.3),
                  blurRadius: 20, offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(child: Text(
              isInvestor ? 'Comprar mais tokens' : 'Simular Investimento',
              style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
              ),
            )),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTokens(int n) {
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    );
  }

  void _mostrarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ModalInvestimento(startup: startup),
    );
  }
}

class _FinCard extends StatelessWidget {
  final String label;
  final String valor;
  final String sub;
  const _FinCard({required this.label, required this.valor, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF999999), fontSize: 11)),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(
          color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 10)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABA: SÓCIOS
// ═══════════════════════════════════════════════════════════════════════════
class _AbaSocios extends StatelessWidget {
  final Startup startup;
  const _AbaSocios({required this.startup});

  @override
  Widget build(BuildContext context) {
    final comPercentual = startup.socios.where((s) => s.percentual > 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Estrutura Societária
        _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Estrutura Societária', style: TextStyle(
            color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 12),
          ...comPercentual.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(s.avatar, style: const TextStyle(
                      color: _primaryBlue, fontSize: 9, fontWeight: FontWeight.w700,
                    ))),
                  ),
                  const SizedBox(width: 8),
                  Text(s.nome, style: const TextStyle(
                    color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600,
                  )),
                ]),
                Text('${s.percentual}%', style: const TextStyle(
                  color: _primaryBlue, fontSize: 13, fontWeight: FontWeight.w700,
                )),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 6,
                  decoration: const BoxDecoration(color: _cardBorder),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: s.percentual / 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_primaryBlue, _green],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          )),
        ])),

        const SizedBox(height: 12),

        // Fundadores
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Fundadores', style: TextStyle(
            color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
          )),
        ),

        ...startup.socios.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _Card(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [_primaryBlue, _bgDark],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(s.avatar, style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700,
                ))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.nome, style: const TextStyle(
                  color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
                )),
                const SizedBox(height: 1),
                Text(s.cargo.split(',').first, style: const TextStyle(
                  color: _primaryBlue, fontSize: 12,
                )),
                if (s.descricao.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(s.descricao, style: const TextStyle(
                    color: Color(0xFF777777), fontSize: 12, height: 1.5,
                  )),
                ],
              ])),
            ]),
          ),
        )),

        // Mentores
        if (startup.mentores.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Text('Conselho e Mentores', style: TextStyle(
              color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
            )),
          ),
          ...startup.mentores.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Card(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: _cardBorder, shape: BoxShape.circle,
                  ),
                  child: Center(child: Text(m.avatar, style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w700,
                  ))),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m.nome, style: const TextStyle(
                    color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600,
                  )),
                  Text(m.cargo, style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 12,
                  )),
                ])),
              ]),
            ),
          )),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABA: PERGUNTAS
// ═══════════════════════════════════════════════════════════════════════════
class _AbaPerguntas extends StatefulWidget {
  final Startup startup;
  final bool canSendPrivateQuestions;
  final StartupService service;

  const _AbaPerguntas({
    required this.startup,
    required this.canSendPrivateQuestions,
    required this.service,
  });

  @override
  State<_AbaPerguntas> createState() => _AbaPerguntasState();
}

class _AbaPerguntasState extends State<_AbaPerguntas> {
  String? _expandedId;
  final Set<String> _liked = {};

  @override
  Widget build(BuildContext context) {
    final perguntas = widget.startup.perguntas;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Subtítulo
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '${perguntas.length} ${perguntas.length == 1 ? "pergunta" : "perguntas"} da comunidade',
            style: const TextStyle(color: Color(0xFF999999), fontSize: 12),
          ),
        ),

        // Acordeão de perguntas
        ...perguntas.map((p) {
          final expanded = _expandedId == p.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              decoration: BoxDecoration(
                color: _cardBg,
                border: Border.all(color: _cardBorder),
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(children: [

                // Cabeçalho clicável
                GestureDetector(
                  onTap: () => setState(() => _expandedId = expanded ? null : p.id),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(child: Text(p.pergunta, style: const TextStyle(
                        color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,
                      ))),
                      const SizedBox(width: 8),
                      Icon(
                        expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: expanded ? _primaryBlue : _iconInactive,
                        size: 20,
                      ),
                    ]),
                  ),
                ),

                // Corpo
                if (expanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                      // Caixa azul clara com resposta
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(p.resposta, style: const TextStyle(
                          color: Color(0xFF444444), fontSize: 13, height: 1.6,
                        )),
                      ),

                      const SizedBox(height: 12),

                      // Ações
                      Row(children: [
                        GestureDetector(
                          onTap: () => setState(() {
                            _liked.contains(p.id) ? _liked.remove(p.id) : _liked.add(p.id);
                          }),
                          child: Row(children: [
                            Icon(
                              _liked.contains(p.id) ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                              size: 14,
                              color: _liked.contains(p.id) ? _primaryBlue : const Color(0xFFAAAAAA),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${p.likes + (_liked.contains(p.id) ? 1 : 0)}',
                              style: TextStyle(
                                color: _liked.contains(p.id) ? _primaryBlue : const Color(0xFFAAAAAA),
                                fontSize: 13,
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(width: 16),
                        Row(children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFFAAAAAA)),
                          const SizedBox(width: 4),
                          Text('${p.comments}', style: const TextStyle(
                            color: Color(0xFFAAAAAA), fontSize: 13,
                          )),
                        ]),
                      ]),
                    ]),
                  ),
              ]),
            ),
          );
        }),

        // Botão fazer pergunta
        GestureDetector(
          onTap: () => _mostrarModalPergunta(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _primaryBlue.withOpacity(0.3), width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.chat_bubble_outline_rounded, color: _primaryBlue, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.canSendPrivateQuestions
                    ? 'Fazer uma pergunta pública ou privada'
                    : 'Fazer uma pergunta',
                style: const TextStyle(
                  color: _primaryBlue, fontSize: 14, fontWeight: FontWeight.w600,
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  void _mostrarModalPergunta(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          const Text('Fazer uma pergunta', style: TextStyle(
            color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
          )),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escreva sua pergunta para os fundadores...',
              hintStyle: const TextStyle(color: Color(0xFF999999)),
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.pop(ctx),
            child: Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_primaryBlue, _primaryDark]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(child: Text('Enviar Pergunta', style: TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
              ))),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABA: MÍDIA
// ═══════════════════════════════════════════════════════════════════════════
class _AbaMidia extends StatelessWidget {
  final Startup startup;
  final List<String> demoVideos;
  final String? pitchDeckUrl;

  const _AbaMidia({required this.startup, required this.demoVideos, required this.pitchDeckUrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // Cards de vídeo
        ..._buildVideoCards(),

        // Materiais adicionais
        if (pitchDeckUrl != null || startup.materiais.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Text('Materiais Adicionais', style: TextStyle(
              color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
            )),
          ),
          if (pitchDeckUrl != null)
            _MaterialCard(titulo: 'Deck de Investimento', tipo: 'PDF', tamanho: '-'),
          ...startup.materiais.map((m) =>
              _MaterialCard(titulo: m.titulo, tipo: m.tipo, tamanho: m.tamanho),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildVideoCards() {
    final videos = demoVideos.isNotEmpty
        ? demoVideos.asMap().entries.map((e) => _VideoCard(
      title: e.key == 0 ? 'Vídeo Demonstrativo' : 'Apresentação ${e.key + 1}',
      subtitle: 'Pitch da ${startup.nome}',
      duration: '--:--',
      url: e.value,
    )).toList()
        : [
      _VideoCard(title: 'Vídeo Demonstrativo', subtitle: 'Pitch principal da ${startup.nome}', duration: '5:32', url: null),
      const _VideoCard(title: 'Apresentação dos Sócios', subtitle: 'Entrevista com os fundadores', duration: '3:15', url: null),
    ];

    return videos.map((v) => Padding(padding: const EdgeInsets.only(bottom: 12), child: v)).toList();
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String? url;

  const _VideoCard({required this.title, required this.subtitle, required this.duration, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Thumbnail
        SizedBox(
          height: 144, width: double.infinity,
          child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF020C14), Color(0xFF0F2050)],
                ),
              ),
            ),
            Center(child: Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: _primaryBlue, size: 30),
            )),
            Positioned(
              left: 12, bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(duration, style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ]),
        ),

        // Info
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(
              color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String tamanho;

  const _MaterialCard({required this.titulo, required this.tipo, required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Card(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insert_drive_file_outlined, color: Color(0xFFE53E3E), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(
              color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
            )),
            Text('$tipo · $tamanho', style: const TextStyle(
              color: Color(0xFF999999), fontSize: 12,
            )),
          ])),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.download_rounded, color: _primaryBlue, size: 16),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODAL: SIMULAR INVESTIMENTO
// ═══════════════════════════════════════════════════════════════════════════
class _ModalInvestimento extends StatefulWidget {
  final Startup startup;
  const _ModalInvestimento({required this.startup});

  @override
  State<_ModalInvestimento> createState() => _ModalInvestimentoState();
}

class _ModalInvestimentoState extends State<_ModalInvestimento> {
  final _controller = TextEditingController();
  bool _success = false;
  int _tokensToGet = 0;
  double _amountNum = 0;

  static const _quickAmounts = ['R\$ 100', 'R\$ 500', 'R\$ 1.000', 'R\$ 5.000'];
  String? _selectedQuick;

  double get _pricePerToken => widget.startup.tokenPriceValue;

  void _calcular(String val) {
    final clean = val.replaceAll('R\$ ', '').replaceAll('.', '').replaceAll(',', '.');
    final num = double.tryParse(clean) ?? 0;
    setState(() {
      _amountNum = num;
      _tokensToGet = _pricePerToken > 0 ? (num / _pricePerToken).floor() : 0;
    });
  }

  void _confirmar() {
    setState(() => _success = true);
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccess();
    return _buildForm();
  }

  Widget _buildSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: _green, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('Investimento realizado!', style: TextStyle(
          color: _textPrimary, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 8),
        Text('$_tokensToGet tokens adicionados à sua carteira.',
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
      ]),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Drag pill
        Center(child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 16),

        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Simular Investimento', style: TextStyle(
              color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
            )),
            Text('${widget.startup.nome} · ${widget.startup.tokenPrice}/token',
                style: const TextStyle(color: Color(0xFF888888), fontSize: 12)),
          ]),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F8), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF666666)),
            ),
          ),
        ]),

        const SizedBox(height: 16),

        // Quick amounts
        Wrap(spacing: 8, runSpacing: 8, children: _quickAmounts.map((q) {
          final active = _selectedQuick == q;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedQuick = q);
              final val = q.replaceAll('R\$ ', '').replaceAll('.', '');
              _controller.text = val;
              _calcular(val);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _primaryBlue : const Color(0xFFF5F6F8),
                border: Border.all(color: active ? _primaryBlue : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(q, style: TextStyle(
                color: active ? Colors.white : _textPrimary,
                fontSize: 13, fontWeight: FontWeight.w500,
              )),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),

        // Campo de valor
        const Text('Valor a investir (R\$)', style: TextStyle(
          color: Color(0xFF666666), fontSize: 12, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _calcular,
          style: const TextStyle(
            color: _textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),

        // Preview
        if (_tokensToGet > 0) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tokens a receber', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text('$_tokensToGet', style: const TextStyle(
                  color: _primaryBlue, fontSize: 18, fontWeight: FontWeight.w700,
                )),
              ]),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Valor total', style: TextStyle(color: Color(0xFF666666), fontSize: 13)),
                Text(_formatBRL(_tokensToGet * _pricePerToken), style: const TextStyle(
                  color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
                )),
              ]),
            ]),
          ),
        ],

        const SizedBox(height: 16),

        // Botão confirmar
        GestureDetector(
          onTap: _tokensToGet > 0 ? _confirmar : null,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              gradient: _tokensToGet > 0
                  ? const LinearGradient(colors: [_primaryBlue, _primaryDark])
                  : null,
              color: _tokensToGet > 0 ? null : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(24),
              boxShadow: _tokensToGet > 0 ? [
                BoxShadow(color: _primaryBlue.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
              ] : null,
            ),
            child: Center(child: Text(
              _tokensToGet > 0 ? 'Confirmar · $_tokensToGet tokens' : 'Informe um valor',
              style: TextStyle(
                color: _tokensToGet > 0 ? Colors.white : Colors.white.withOpacity(0.4),
                fontSize: 16, fontWeight: FontWeight.w700,
              ),
            )),
          ),
        ),

        const SizedBox(height: 12),

        // Rodapé
        const Center(child: Text(
          '⚠️ Operação simulada · Sem envolvimento de ativos reais',
          style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          textAlign: TextAlign.center,
        )),
      ]),
    );
  }

  String _formatBRL(double v) {
    final s = v.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final buf = StringBuffer();
    final intPart = parts[0];
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
      buf.write(intPart[i]);
    }
    return 'R\$ $buf,${parts[1]}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGETS UTILITÁRIOS
// ═══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _Shimmer(width: 68, height: 68, radius: 16),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Shimmer(width: 160, height: 20, radius: 6),
          const SizedBox(height: 8),
          _Shimmer(width: 120, height: 14, radius: 6),
          const SizedBox(height: 8),
          _Shimmer(width: 80, height: 20, radius: 6),
        ])),
      ]),
      const SizedBox(height: 12),
      _Shimmer(width: double.infinity, height: 14, radius: 6),
      const SizedBox(height: 6),
      _Shimmer(width: 200, height: 14, radius: 6),
    ]);
  }
}

class _HeaderErro extends StatelessWidget {
  final VoidCallback onRetry;
  const _HeaderErro({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 18),
      const SizedBox(width: 8),
      const Text('Erro ao carregar', style: TextStyle(color: Colors.white54, fontSize: 13)),
      const Spacer(),
      TextButton(onPressed: onRetry, child: const Text('Tentar novamente',
          style: TextStyle(color: _primaryBlue, fontSize: 13))),
    ]);
  }
}

class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 10),
        Row(children: List.generate(5, (_) => Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _Shimmer(width: 50, height: 40, radius: 6),
        ))),
        const SizedBox(height: 20),
        _Shimmer(width: double.infinity, height: 100, radius: 16),
        const SizedBox(height: 12),
        _Shimmer(width: double.infinity, height: 80, radius: 16),
      ]),
    );
  }
}

class _TelaErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;
  const _TelaErro({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: Colors.grey, size: 48),
        const SizedBox(height: 12),
        const Text('Não foi possível carregar os dados', style: TextStyle(
          color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        Text(mensagem, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Tentar novamente'),
        ),
      ]),
    ));
  }
}

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// Helper
String _initials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}