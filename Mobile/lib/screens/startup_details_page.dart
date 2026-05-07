import 'package:flutter/material.dart';
import '../models/startup_model.dart';
import '../services/startup_service.dart';
import '../theme/app_colors.dart';
import '../widgets/notificacao.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STARTUP DETAILS PAGE
//
// Aceita dois modos de uso:
//
// 1. Com dados locais (mock/catálogo):
//    StartupDetailsPage(startup: startupObj)
//
// 2. Buscando do Firebase pelo ID:
//    StartupDetailsPage(startupId: 'biochip-campus', idToken: token)
//
// Quando `startup` é passado, ele é exibido imediatamente.
// Quando só `startupId` é passado, o service é chamado e exibe loading.
// ─────────────────────────────────────────────────────────────────────────────
class StartupDetailsPage extends StatefulWidget {
  /// Startup já carregada (mock ou catálogo local)
  final Startup? startup;

  /// ID para buscar no Firebase
  final String? startupId;

  const StartupDetailsPage({
    super.key,
    this.startup,
    this.startupId,
  }) : assert(
  startup != null || startupId != null,
  'Informe startup ou startupId',
  );

  @override
  State<StartupDetailsPage> createState() => _StartupDetailsPageState();
}

class _StartupDetailsPageState extends State<StartupDetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Estado da tela
  Startup? _startup;
  bool _loading = false;
  String? _error;

  // access flags vindos do Firebase (getStartupDetails → access)
  bool _isInvestor = false;
  bool _canTradeTokens = false;
  bool _canSendPrivateQuestions = false;

  // vídeos e pitchDeckUrl vindos diretamente do Firebase
  List<String> _demoVideos = [];
  String? _pitchDeckUrl;
  String? _coverImageUrl;

  // tags da startup
  List<String> _tags = [];

  final List<({IconData icon, String label})> _tabs = const [
    (icon: Icons.info_outline_rounded, label: 'Geral'),
    (icon: Icons.monetization_on_outlined, label: 'Financeiro'),
    (icon: Icons.people_outline_rounded, label: 'Sócios'),
    (icon: Icons.chat_bubble_outline_rounded, label: 'Perguntas'),
    (icon: Icons.play_circle_outline_rounded, label: 'Mídia'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    if (widget.startup != null) {
      _startup = widget.startup;
    } else {
      _fetchFromFirebase();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFromFirebase() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // getStartupDetails retorna um StartupDetailsResult com startup + campos extras
      final result = await StartupService.instance.getStartupDetails(
        widget.startupId!,
      );

      if (mounted) {
        setState(() {
          _startup = result.startup;
          _isInvestor = result.isInvestor;
          _canTradeTokens = result.canTradeTokens;
          _canSendPrivateQuestions = result.canSendPrivateQuestions;
          _demoVideos = result.demoVideos;
          _pitchDeckUrl = result.pitchDeckUrl;
          _coverImageUrl = result.coverImageUrl;
          _tags = result.tags;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header sempre visível (com ou sem dados) ─────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão voltar
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Header com dados ou skeleton
                  _loading
                      ? const _HeaderSkeleton()
                      : _error != null
                      ? _HeaderError(onRetry: _fetchFromFirebase)
                      : _startup != null
                      ? _HeaderContent(
                    startup: _startup!,
                    tags: _tags,
                    coverImageUrl: _coverImageUrl,
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          // ── Bottom sheet branca ──────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: _loading || _error != null || _startup == null
                  ? _loading
                  ? const _ContentSkeleton()
                  : _error != null
                  ? _ErrorBody(
                message: _error!,
                onRetry: _fetchFromFirebase,
              )
                  : const SizedBox.shrink()
                  : Column(
                children: [
                  // Drag indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                    labelPadding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey[400],
                    dividerColor: Colors.grey[100],
                    tabs: _tabs
                        .map(
                          (t) => Tab(
                        height: 52,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, size: 16),
                            const SizedBox(height: 3),
                            Text(
                              t.label,
                              style:
                              const TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),

                  // Conteúdo das tabs
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _GeralTab(startup: _startup!),
                        _FinanceiroTab(
                          startup: _startup!,
                          isInvestor: _isInvestor,
                          canTradeTokens: _canTradeTokens,
                        ),
                        _SociosTab(startup: _startup!),
                        _PerguntasTab(
                          startup: _startup!,
                          canSendPrivateQuestions: _canSendPrivateQuestions,
                          onRefresh: _fetchFromFirebase, // Adiciona esta linha
                        ),
                        _MidiaTab(
                          startup: _startup!,
                          demoVideos: _demoVideos,
                          pitchDeckUrl: _pitchDeckUrl,
                        ),
                      ],
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// HEADER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderContent extends StatelessWidget {
  final Startup s;
  final List<String> tags;
  final String? coverImageUrl;

  const _HeaderContent({
    required Startup startup,
    required this.tags,
    required this.coverImageUrl,
  }) : s = startup;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo: tenta coverImageUrl (Firebase), fallback para asset local,
            // fallback para iniciais
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _StartupLogo(
                networkUrl: coverImageUrl,
                assetPath: s.logoAsset,
                initials: s.nome.length >= 2
                    ? s.nome.substring(0, 2).toUpperCase()
                    : s.nome.toUpperCase(),
                size: 70,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          s.status,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Text(
                          s.variacao,
                          style: TextStyle(
                            color: s.variacaoPositiva
                                ? AppColors.positive
                                : AppColors.negative,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Badge do setor (stage do Firebase) + código da startup
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            s.setor,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '#${s.codigo}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // shortDescription do Firebase
        Text(
          s.descricaoBreve,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            height: 1.5,
          ),
        ),

        // Tags vindas do Firebase (tags: string[])
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.15)),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Skeleton do header enquanto carrega
class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Shimmer(width: 70, height: 70, radius: 16),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 160, height: 22, radius: 6),
                  const SizedBox(height: 8),
                  _Shimmer(width: 100, height: 14, radius: 6),
                  const SizedBox(height: 8),
                  _Shimmer(width: 80, height: 22, radius: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Shimmer(width: double.infinity, height: 14, radius: 6),
        const SizedBox(height: 6),
        _Shimmer(width: 240, height: 14, radius: 6),
        const SizedBox(height: 12),
        Row(
          children: [
            _Shimmer(width: 60, height: 22, radius: 20),
            const SizedBox(width: 6),
            _Shimmer(width: 70, height: 22, radius: 20),
          ],
        ),
      ],
    );
  }
}

class _HeaderError extends StatelessWidget {
  final VoidCallback onRetry;
  const _HeaderError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 20),
        const SizedBox(width: 8),
        const Text(
          'Erro ao carregar startup',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const Spacer(),
        TextButton(
          onPressed: onRetry,
          child: const Text('Tentar novamente',
              style: TextStyle(color: AppColors.primary, fontSize: 13)),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.grey, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar os dados',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton do conteúdo (bottom sheet)
class _ContentSkeleton extends StatelessWidget {
  const _ContentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Tab bar fake
          Row(
            children: List.generate(
              5,
                  (_) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _Shimmer(width: 48, height: 40, radius: 6),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _Shimmer(width: double.infinity, height: 100, radius: 16),
          const SizedBox(height: 12),
          _Shimmer(width: double.infinity, height: 80, radius: 16),
          const SizedBox(height: 12),
          _Shimmer(width: double.infinity, height: 80, radius: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER (placeholder animado)
// ─────────────────────────────────────────────────────────────────────────────

class _Shimmer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _Shimmer({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGO DA STARTUP
// Tenta: 1) coverImageUrl (Firebase network), 2) asset local, 3) iniciais
// ─────────────────────────────────────────────────────────────────────────────

class _StartupLogo extends StatelessWidget {
  final String? networkUrl;
  final String assetPath;
  final String initials;
  final double size;

  const _StartupLogo({
    required this.networkUrl,
    required this.assetPath,
    required this.initials,
    required this.size,
  });

  Widget _fallback() => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.background],
      ),
    ),
    child: Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.28,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // 1. Tenta imagem de rede (coverImageUrl do Firebase)
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    // 2. Tenta asset local
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS COMPARTILHADOS ENTRE AS TABS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _SectionCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  final bool muted;

  const _AvatarCircle({
    required this.initials,
    this.size = 44,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: muted
            ? const LinearGradient(
          colors: [Color(0xFF9DB2CE), Color(0xFF6B8FA8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.background],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: GERAL
// Exibe: seções geral (executiveSummary + description do Firebase),
//        card de preço do token
// ─────────────────────────────────────────────────────────────────────────────

class _GeralTab extends StatelessWidget {
  final Startup startup;
  const _GeralTab({required this.startup});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Seções: montadas em startup_service.dart a partir de
        // executiveSummary e description do Firebase
        ...startup.geral.map(
              (secao) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    secao.titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secao.conteudo,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Mensagem quando Firebase não retornou nenhuma seção
        if (startup.geral.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SectionCard(
              child: Column(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.grey[300], size: 36),
                  const SizedBox(height: 8),
                  Text(
                    'Informações detalhadas em breve.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // Card de preço do token (currentTokenPriceCents do Firebase)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.background, AppColors.darkBlue],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preço do Token',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    startup.tokenPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      startup.variacao,
                      style: TextStyle(
                        color: startup.variacaoPositiva
                            ? AppColors.positive
                            : AppColors.negative,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: FINANCEIRO
// Dados: capitalRaisedCents, totalTokensIssued, currentTokenPriceCents
//        campos placeholder (previsaoReceita, cpv, margemBrutaAlvo) vêm
//        como '-' quando Firebase não os retorna
//
// Flags de acesso: isInvestor e canTradeTokens vêm de access do Firebase
// ─────────────────────────────────────────────────────────────────────────────

class _FinanceiroTab extends StatelessWidget {
  final Startup startup;
  final bool isInvestor;
  final bool canTradeTokens;

  const _FinanceiroTab({
    required this.startup,
    required this.isInvestor,
    required this.canTradeTokens,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Capital aportado (capitalRaisedCents convertido pelo service)
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Capital Aportado',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    startup.capitalAportado,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('(Simulado)',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Tokens emitidos (totalTokensIssued do Firebase)
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tokens Emitidos',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                startup.tokensEmitidos.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]}.',
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Representação digital de participação',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Mini resumo financeiro
        // previsaoReceita, cpv, margemBrutaAlvo mostram '-' quando Firebase
        // não retorna (campos não existem no getStartupDetails atual)
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mini Resumo Financeiro',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _FinRow(
                  label: 'Previsão de Receita (2026)',
                  value: startup.previsaoReceita),
              const _Divider(),
              _FinRow(label: 'CPV', value: startup.cpv),
              const _Divider(),
              _FinRow(
                  label: 'Margem Bruta Alvo',
                  value: startup.margemBrutaAlvo),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Badge de investidor — exibido quando access.isInvestor == true
        if (isInvestor)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.positive.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.positive.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.positive, size: 20),
                const SizedBox(width: 10),
                const Text(
                  'Você é investidor desta startup',
                  style: TextStyle(
                    color: AppColors.positive,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // Botão de simular investimento
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showInvestModal(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Simular Investimento',
              style:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        // Botão de vender tokens — visível apenas quando canTradeTokens == true
        if (canTradeTokens) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Vender Tokens',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  void _showInvestModal(BuildContext context) {
    final controller = TextEditingController();
    int tokens = 0;
    double proj = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          void calc() {
            final amt = double.tryParse(
                controller.text.replaceAll(',', '.')) ??
                0;
            tokens = startup.tokenPriceValue > 0
                ? (amt / startup.tokenPriceValue).floor()
                : 0;
            proj = amt * 1.15;
            setModal(() {});
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24,
                MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Simular Investimento',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  startup.nome,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  onChanged: (_) => calc(),
                  decoration: InputDecoration(
                    labelText: 'Valor a investir (R\$)',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                if (tokens > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SimRow(
                          label: 'Tokens recebidos',
                          value: '$tokens tokens',
                        ),
                        const SizedBox(height: 8),
                        _SimRow(
                          label: 'Projeção (+15%)',
                          value:
                          'R\$ ${proj.toStringAsFixed(2).replaceAll('.', ',')}',
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tokens > 0
                        ? () => Navigator.pop(ctx)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[200],
                      padding:
                      const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Confirmar Investimento',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  final String label;
  final String value;

  const _FinRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: value == '-'
                  ? Colors.grey[300]
                  : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      Divider(height: 1, color: Colors.grey[100]);
}

class _SimRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SimRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.positive : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: SÓCIOS
// Dados: founders → socios, externalMembers → mentores (mapeados no service)
// ─────────────────────────────────────────────────────────────────────────────

class _SociosTab extends StatelessWidget {
  final Startup startup;
  const _SociosTab({required this.startup});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estrutura societária com barras de progresso
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estrutura Societária',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              ...startup.socios.map(
                    (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _AvatarCircle(initials: s.avatar, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.nome,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${s.percentual}%',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: s.percentual / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey[100],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Apresentação dos sócios (founders com bio do Firebase)
        const Text(
          'Apresentação dos Sócios',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...startup.socios.map(
              (s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SectionCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarCircle(initials: s.avatar, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.nome,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          // cargo pode vir como "CEO" ou "CEO, Empresa"
                          s.cargo.split(',').first,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (s.descricao.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            s.descricao,
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Conselho e Mentores (externalMembers do Firebase)
        if (startup.mentores.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text(
            'Conselho e Mentores',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...startup.mentores.map(
                (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SectionCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _AvatarCircle(
                        initials: m.avatar, size: 40, muted: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.nome,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          // cargo do mentor: "Cargo, Organização" (montado no service)
                          Text(
                            m.cargo,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: PERGUNTAS
// Dados: publicQuestions do Firebase → perguntas (mapeado no service)
// Flag: canSendPrivateQuestions (access do Firebase)
// ─────────────────────────────────────────────────────────────────────────────

class _PerguntasTab extends StatefulWidget {
  final Startup startup;
  final bool canSendPrivateQuestions;
  final VoidCallback onRefresh; // NOVO: Callback para atualizar a tela

  const _PerguntasTab({
    required this.startup,
    required this.canSendPrivateQuestions,
    required this.onRefresh,
  });

  @override
  State<_PerguntasTab> createState() => _PerguntasTabState();
}

class _PerguntasTabState extends State<_PerguntasTab> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final perguntas = widget.startup.perguntas;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${perguntas.length} pergunta${perguntas.length == 1 ? '' : 's'} da comunidade',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),

        if (perguntas.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.grey[200], size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Nenhuma pergunta ainda.\nSeja o primeiro!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ...perguntas.asMap().entries.map(
                (e) => _FaqItem(
              index: e.key,
              pergunta: e.value,
              isExpanded: _expanded.contains(e.key),
              onToggle: () => setState(() {
                _expanded.contains(e.key)
                    ? _expanded.remove(e.key)
                    : _expanded.add(e.key);
              }),
            ),
          ),

        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => _showAskSheet(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.canSendPrivateQuestions
                      ? 'Fazer uma pergunta pública ou privada'
                      : 'Fazer uma pergunta',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAskSheet(BuildContext context) {
    final controller = TextEditingController();
    bool isPrivate = false;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fazer uma pergunta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Escreva sua pergunta para os fundadores...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (_) => setModalState(() {}), // Atualiza pra habilitar botão
                ),
                if (widget.canSendPrivateQuestions) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Enviar como pergunta privada', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Visível apenas para você e os fundadores', style: TextStyle(fontSize: 12)),
                    value: isPrivate,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setModalState(() => isPrivate = val),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting || controller.text.trim().isEmpty
                        ? null
                        : () async {
                      setModalState(() => isSubmitting = true);
                      try {
                        await StartupService.instance.createStartupQuestion(
                          startupId: widget.startup.id,
                          text: controller.text.trim(),
                          visibility: isPrivate ? 'privada' : 'publica',
                        );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          Notificacao.sucesso(context, 'Pergunta enviada com sucesso!');
                        }
                        widget.onRefresh(); // Chama o refresh pra carregar a pergunta nova
                      } catch (e) {
                        if (context.mounted) {
                          Notificacao.erro(context, 'Erro ao enviar pergunta. Tente novamente.');
                        }
                      } finally {
                        if (ctx.mounted) {
                          setModalState(() => isSubmitting = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Enviar Pergunta',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final int index;
  final Pergunta pergunta;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FaqItem({
    required this.index,
    required this.pergunta,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header da FAQ
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pergunta.pergunta,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Corpo da FAQ
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 1, color: Colors.grey[100]),
                  const SizedBox(height: 12),
                  Text(
                    // answer pode ser null no Firebase — service usa 'Sem resposta ainda.'
                    pergunta.resposta,
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ReactionButton(
                        icon: Icons.thumb_up_outlined,
                        count: pergunta.likes,
                      ),
                      const SizedBox(width: 16),
                      _ReactionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        count: pergunta.comments,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final int count;

  const _ReactionButton({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB: MÍDIA
// Dados: demoVideos (URLs do Firebase), pitchDeckUrl, materiais do startup
//
// demoVideos e pitchDeckUrl são passados diretamente da página pai
// pois não estão no modelo Startup — vêm separados do getStartupDetails
// ─────────────────────────────────────────────────────────────────────────────

class _MidiaTab extends StatelessWidget {
  final Startup startup;
  final List<String> demoVideos;
  final String? pitchDeckUrl;

  const _MidiaTab({
    required this.startup,
    required this.demoVideos,
    required this.pitchDeckUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vídeos do Firebase (demoVideos: string[])
        // Se não tiver nenhum, mostra cards placeholder
        if (demoVideos.isEmpty) ...[
          _VideoCard(
            title: 'Vídeo Demonstrativo',
            subtitle: 'Pitch principal da ${startup.nome}',
            duration: '5:32',
            gradientColors: const [AppColors.background, AppColors.darkBlue],
            playColor: AppColors.primary,
            url: null,
          ),
          const SizedBox(height: 12),
          _VideoCard(
            title: 'Apresentação dos Sócios',
            subtitle: 'Entrevista com os fundadores',
            duration: '3:15',
            gradientColors: const [Color(0xFF1A3A2A), Color(0xFF0A2015)],
            playColor: AppColors.positive,
            url: null,
          ),
        ] else
          ...demoVideos.asMap().entries.map(
                (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _VideoCard(
                title: e.key == 0
                    ? 'Vídeo Demonstrativo'
                    : 'Apresentação ${e.key + 1}',
                subtitle: 'Pitch da ${startup.nome}',
                duration: '--:--',
                gradientColors: e.key == 0
                    ? const [AppColors.background, AppColors.darkBlue]
                    : const [Color(0xFF1A3A2A), Color(0xFF0A2015)],
                playColor: e.key == 0
                    ? AppColors.primary
                    : AppColors.positive,
                url: e.value,
              ),
            ),
          ),

        const SizedBox(height: 4),

        // Materiais adicionais:
        // 1. pitchDeckUrl do Firebase (se existir)
        // 2. materiais do modelo Startup (do catálogo local)
        if (pitchDeckUrl != null || startup.materiais.isNotEmpty) ...[
          const Text(
            'Materiais Adicionais',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // Deck de investimento vindo do Firebase (pitchDeckUrl)
          if (pitchDeckUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MaterialCard(
                titulo: 'Deck de Investimento',
                tipo: 'PDF',
                tamanho: '-',
                url: pitchDeckUrl,
              ),
            ),

          // Demais materiais do modelo (catálogo local)
          ...startup.materiais.map(
                (mat) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MaterialCard(
                titulo: mat.titulo,
                tipo: mat.tipo,
                tamanho: mat.tamanho,
                url: null,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final List<Color> gradientColors;
  final Color playColor;
  final String? url;

  const _VideoCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.gradientColors,
    required this.playColor,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: url != null ? () {} : null, // TODO: abrir url no browser
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            color: playColor, size: 28),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final String titulo;
  final String tipo;
  final String tamanho;
  final String? url;

  const _MaterialCard({
    required this.titulo,
    required this.tipo,
    required this.tamanho,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded,
                color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  tamanho != '-' ? '$tipo • $tamanho' : tipo,
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: url != null ? () {} : null, // TODO: abrir url
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: url != null
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                color: url != null ? AppColors.primary : Colors.grey[300],
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}