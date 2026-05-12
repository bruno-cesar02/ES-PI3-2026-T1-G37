import 'package:cloud_functions/cloud_functions.dart';
import '../models/startup_model.dart';

class StartupService {
  static final StartupService instance = StartupService._();
  StartupService._();

  final _functions = FirebaseFunctions.instanceFor(region: 'southamerica-east1');

  Future<StartupDetailsResult> getStartupDetails(String startupId) async {
    final callable = _functions.httpsCallable('getStartupDetails');
    final result = await callable.call({'id': startupId});
    final raw = Map<String, dynamic>.from(result.data as Map);
    final data = Map<String, dynamic>.from(raw['data'] as Map);
    print('DADOS RECEBIDOS: $data'); // ← adiciona isso
    return _mapToResult(data);
  }

  
  Future<void> createStartupQuestion({
    required String startupId,
    required String text,
    required String visibility,
  }) async {
    final callable = _functions.httpsCallable('createStartupQuestion');
    await callable.call({
      'startupId': startupId,
      'text': text,
      'visibility': visibility,
    });
  }
}

class StartupDetailsResult {
  final Startup startup;
  final bool isInvestor;
  final bool canTradeTokens;
  final bool canSendPrivateQuestions;
  final List<String> demoVideos;
  final String? pitchDeckUrl;
  final String? coverImageUrl;
  final List<String> tags;

  const StartupDetailsResult({
    required this.startup,
    required this.isInvestor,
    required this.canTradeTokens,
    required this.canSendPrivateQuestions,
    required this.demoVideos,
    required this.pitchDeckUrl,
    required this.coverImageUrl,
    required this.tags,
  });
}

StartupDetailsResult _mapToResult(Map<String, dynamic> data) {
  final access = Map<String, dynamic>.from(data['access'] as Map? ?? {});
  final isInvestor = access['isInvestor'] as bool? ?? false;
  final canTradeTokens = access['canTradeTokens'] as bool? ?? false;
  final canSendPrivateQuestions = access['canSendPrivateQuestions'] as bool? ?? false;

  final demoVideos = (data['demoVideos'] as List? ?? []).map((v) => v.toString()).toList();
  final pitchDeckUrl = data['pitchDeckUrl'] as String?;
  final coverImageUrl = data['coverImageUrl'] as String?;
  final tags = (data['tags'] as List? ?? []).map((t) => t.toString()).toList();


  final listaSocios = data['founder'] ?? data['founders'] ?? [];

  final socios = (listaSocios as List).map((f) {
    final founder = Map<String, dynamic>.from(f as Map);
    return Socio(
      nome: founder['name'] as String? ?? '',
      cargo: founder['role'] as String? ?? '',
      // Busca por 'equityPercentage' ou 'equityPercent'
      percentual: (founder['equityPercentage'] as num? ?? founder['equityPercent'] as num? ?? 0).toInt(),
      descricao: founder['bio'] as String? ?? '',
      avatar: _initials(founder['name'] as String? ?? ''),
    );
  }).toList();

  final mentores = (data['externalMembers'] as List? ?? []).map((m) {
    final member = Map<String, dynamic>.from(m as Map);
    final org = member['organization'] as String?;
    return Mentor(
      nome: member['name'] as String? ?? '',
      cargo: org != null ? '${member['role']}, $org' : member['role'] as String? ?? '',
      avatar: _initials(member['name'] as String? ?? ''),
    );
  }).toList();

  final perguntas = (data['publicQuestions'] as List? ?? []).map((q) {
    final question = Map<String, dynamic>.from(q as Map);
    return Pergunta(
      id: question['id'] as String? ?? '',
      pergunta: question['text'] as String? ?? '',
      resposta: question['answer'] as String? ?? 'Sem resposta ainda.',
      likes: 0,
      comments: 0,
    );
  }).toList();

  final geral = <SecaoGeral>[
    if (_notEmpty(data['executiveSummary']))
      SecaoGeral(titulo: 'Sumário Executivo', conteudo: data['executiveSummary'] as String),
    if (_notEmpty(data['description']))
      SecaoGeral(titulo: 'Descrição Completa', conteudo: data['description'] as String),
  ];

  final capitalCents = (data['capitalRaisedCents'] as num? ?? 0).toInt();
  final tokenPriceCents = (data['currentTokenPriceCents'] as num? ?? 0).toInt();
  final tokensEmitidos = (data['totalTokensIssued'] as num? ?? 0).toInt();
  final stage = data['stage'] as String? ?? 'nova';

  final startup = Startup(
    id: data['id'] as String? ?? '',
    nome: data['name'] as String? ?? '',
    setor: _stageLabel(stage),
    codigo: (data['id'] as String? ?? '').toUpperCase(),
    status: '*${_stageStatus(stage)}',
    descricaoBreve: data['shortDescription'] as String? ?? '',
    logoAsset: 'assets/images/${data['id']}.png',
    capitalAportado: _formatCurrency(capitalCents),
    tokensEmitidos: tokensEmitidos,
    previsaoReceita: '-',
    cpv: '-',
    margemBrutaAlvo: '-',
    tokenPrice: _formatCurrency(tokenPriceCents),
    tokenPriceValue: tokenPriceCents / 100.0,
    variacao: '0,0%',
    variacaoPositiva: true,
    socios: socios,
    mentores: mentores,
    perguntas: perguntas,
    geral: geral,
    materiais: [],
  );

  return StartupDetailsResult(
    startup: startup,
    isInvestor: isInvestor,
    canTradeTokens: canTradeTokens,
    canSendPrivateQuestions: canSendPrivateQuestions,
    demoVideos: demoVideos,
    pitchDeckUrl: pitchDeckUrl,
    coverImageUrl: coverImageUrl,
    tags: tags,
  );
}

String _initials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _formatCurrency(int cents) {
  final reais = cents / 100.0;
  final formatted = reais.toStringAsFixed(2).replaceAll('.', ',');
  final parts = formatted.split(',');
  final buf = StringBuffer();
  final intPart = parts[0];
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write('.');
    buf.write(intPart[i]);
  }
  return 'R\$ $buf,${parts[1]}';
}

bool _notEmpty(dynamic value) => value is String && value.trim().isNotEmpty;

String _stageLabel(String stage) => switch (stage) {
  'nova' => 'Nova',
  'em_operacao' => 'Em Operação',
  'em_expansao' => 'Em Expansão',
  _ => stage,
};

String _stageStatus(String stage) => switch (stage) {
  'nova' => 'Nova no mercado',
  'em_operacao' => 'Em operação',
  'em_expansao' => 'Em expansão',
  _ => stage,
};