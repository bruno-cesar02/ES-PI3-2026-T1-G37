import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = '1M';
  String? selectedStartupId; // Controla qual startup está filtrando o gráfico (null = visão geral)

  final Color bgColor = const Color(0xFF020C14);
  final Color primaryColor = const Color(0xFF386BF6); // Adaptado para o seu azul
  final Color positiveColor = const Color(0xFF00AE51);
  final Color negativeColor = const Color(0xFFEF4444);

  // ─── DADOS FALSOS (MOCK) PARA A INTERFACE ───
  // Lista de tokens na carteira
  final List<Map<String, dynamic>> portfolio = [
    {
      'id': 'demo-startup-karpos',
      'nome': 'Karpós S.A',
      'tokens': 350,
      'valorTotal': 5250.00,
      'variacao': '+1,5%',
      'positiva': true,
      'logoTexto': 'K',
      'logoColor': const Color(0xFF00AE51)
    },
    {
      'id': 'demo-startup-healthai',
      'nome': 'HealthAI',
      'tokens': 289,
      'valorTotal': 3699.20,
      'variacao': '+6,4%',
      'positiva': true,
      'logoTexto': 'AI',
      'logoColor': const Color(0xFF020C14)
    },
    {
      'id': 'demo-startup-ecotech',
      'nome': 'EcoTech',
      'tokens': 156,
      'valorTotal': 1950.00,
      'variacao': '-2,1%',
      'positiva': false,
      'logoTexto': 'ECO',
      'logoColor': const Color(0xFF1E3A8A)
    },
  ];

  // Dados do gráfico: Visão Geral
  final Map<String, List<FlSpot>> generalChartData = {
    '1D': [const FlSpot(0, 60), const FlSpot(1, 75), const FlSpot(2, 55), const FlSpot(3, 80), const FlSpot(4, 65), const FlSpot(5, 88), const FlSpot(6, 72)],
    '1S': [const FlSpot(0, 52), const FlSpot(1, 77), const FlSpot(2, 46), const FlSpot(3, 88), const FlSpot(4, 63), const FlSpot(5, 79), const FlSpot(6, 55)],
    '1M': [const FlSpot(0, 79), const FlSpot(1, 52), const FlSpot(2, 77), const FlSpot(3, 46), const FlSpot(4, 88), const FlSpot(5, 63), const FlSpot(6, 36)],
    '6M': [const FlSpot(0, 30), const FlSpot(1, 42), const FlSpot(2, 55), const FlSpot(3, 48), const FlSpot(4, 70), const FlSpot(5, 60), const FlSpot(6, 82)],
    'YTD': [const FlSpot(0, 20), const FlSpot(1, 35), const FlSpot(2, 50), const FlSpot(3, 45), const FlSpot(4, 68), const FlSpot(5, 75), const FlSpot(6, 88)],
  };

  // Variação percentual para o badge do topo
  final Map<String, String> periodChange = {
    '1D': '+2,1%', '1S': '+3,4%', '1M': '+5,2%', '6M': '+18,7%', 'YTD': '+37,5%',
  };

  // ─── GETTERS DINÂMICOS BASEADOS NA SELEÇÃO ───

  // Retorna os dados do gráfico (Geral ou Específico da Startup)
  List<FlSpot> get currentChartData {
    if (selectedStartupId == null) {
      return generalChartData[selectedPeriod]!;
    }
    // Gerando um dado ligeiramente diferente apenas para simular a mudança visual da startup
    final indexMod = portfolio.indexWhere((p) => p['id'] == selectedStartupId) + 1;
    return generalChartData[selectedPeriod]!.map((spot) => FlSpot(spot.x, spot.y * (1.0 - (indexMod * 0.1)))).toList();
  }

  // Título do patrimônio
  String get topTitle => selectedStartupId == null
      ? 'Patrimônio Total'
      : 'Seus tokens em ${portfolio.firstWhere((p) => p['id'] == selectedStartupId)['nome']}';

  // Valor exibido no topo
  double get topValue {
    if (selectedStartupId == null) {
      return portfolio.fold(0.0, (sum, item) => sum + (item['valorTotal'] as double));
    }
    return portfolio.firstWhere((p) => p['id'] == selectedStartupId)['valorTotal'] as double;
  }

  // Variação exibida no topo
  String get topVariation => selectedStartupId == null
      ? periodChange[selectedPeriod]!
      : portfolio.firstWhere((p) => p['id'] == selectedStartupId)['variacao'] as String;

  bool get isTopVariationPositive => selectedStartupId == null
      ? true
      : portfolio.firstWhere((p) => p['id'] == selectedStartupId)['positiva'] as bool;

  // ─── UI BUILDER ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bem-vindo de volta,', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const Text('Renata Arantes', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Visão Dinâmica (Patrimônio Geral ou Startup Selecionada)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topTitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                          _formatBRL(topValue),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: isTopVariationPositive ? positiveColor.withOpacity(0.15) : negativeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100)
                        ),
                        child: Text(
                            topVariation,
                            style: TextStyle(
                                color: isTopVariationPositive ? positiveColor : negativeColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filtros de Período
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['1D', '1S', '1M', '6M', 'YTD'].map((period) {
                  final isSelected = selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => setState(() => selectedPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isSelected ? primaryColor : Colors.transparent, width: 2))
                      ),
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? primaryColor : const Color(0xFF718096),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Gráfico fl_chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 180,
                padding: const EdgeInsets.only(top: 24, right: 16, left: 4, bottom: 12),
                decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul'];
                                  if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                    return Text(labels[value.toInt()], style: const TextStyle(color: Color(0xFF555555), fontSize: 11));
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: 20,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0 || value == 100) return const SizedBox.shrink();
                                  return Text(value.toInt().toString(), style: const TextStyle(color: Color(0xFF555555), fontSize: 11));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0, maxX: 6, minY: 0, maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: currentChartData, // Dados atualizados dinamicamente!
                              isCurved: true,
                              color: primaryColor,
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) => CircleButtPainter(
                                  color: const Color(0xFF1A1F26),
                                  strokeWidth: 1.5,
                                  strokeColor: primaryColor,
                                  radius: 3.5,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.02)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 16, height: 2, color: primaryColor),
                        const SizedBox(width: 8),
                        const Text('2026', style: TextStyle(color: Colors.black, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              ),
            ),

            // Lista Inferior "Seus Tokens"
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(2)))),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Seus Tokens', style: TextStyle(color: Color(0xFF020C14), fontSize: 18, fontWeight: FontWeight.bold)),
                          if (selectedStartupId != null)
                            GestureDetector(
                              onTap: () => setState(() => selectedStartupId = null),
                              child: const Text('Limpar seleção', style: TextStyle(color: Color(0xFF386BF6), fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: portfolio.length,
                        separatorBuilder: (context, index) => const Divider(color: Color(0xFFF0F0F0), height: 1),
                        itemBuilder: (context, index) {
                          final item = portfolio[index];
                          final isSelected = selectedStartupId == item['id'];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                // Se clicar no que já está selecionado, ele desmarca
                                selectedStartupId = isSelected ? null : item['id'];
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSelected ? primaryColor.withOpacity(0.3) : Colors.transparent),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56, height: 56,
                                    decoration: BoxDecoration(color: item['logoColor'], borderRadius: BorderRadius.circular(14)),
                                    child: Center(child: Text(item['logoTexto'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['nome'], style: const TextStyle(color: Color(0xFF020C14), fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 2),
                                        Text('${item['tokens']} tokens', style: const TextStyle(color: Color(0xFF505050), fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(_formatBRL(item['valorTotal']), style: const TextStyle(color: Color(0xFF020C14), fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                          item['variacao'],
                                          style: TextStyle(color: item['positiva'] ? positiveColor : negativeColor, fontSize: 13, fontWeight: FontWeight.w600)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBRL(double value) {
    final s = value.toStringAsFixed(2).replaceAll('.', ',');
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

// Pintor customizado para replicar exatamente a bolinha do Recharts
// Pintor customizado para replicar exatamente a bolinha do Recharts
class CircleButtPainter extends FlDotPainter {
  final Color color;
  final double radius;
  final Color strokeColor;
  final double strokeWidth;

  CircleButtPainter({
    required this.color,
    required this.radius,
    required this.strokeColor,
    required this.strokeWidth
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(offsetInCanvas, radius, paint);
    canvas.drawCircle(offsetInCanvas, radius, strokePaint);
  }

  @override
  Size getSize(FlSpot spot) => Size(radius * 2, radius * 2);

  // ─── IMPLEMENTAÇÕES OBRIGATÓRIAS ADICIONADAS ───
  @override
  Color get mainColor => color;

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is! CircleButtPainter || b is! CircleButtPainter) return this;
    return CircleButtPainter(
      color: Color.lerp(a.color, b.color, t) ?? color,
      radius: a.radius + (b.radius - a.radius) * t,
      strokeColor: Color.lerp(a.strokeColor, b.strokeColor, t) ?? strokeColor,
      strokeWidth: a.strokeWidth + (b.strokeWidth - a.strokeWidth) * t,
    );
  }
  // ───────────────────────────────────────────────

  @override
  List<Object?> get props => [color, radius, strokeColor, strokeWidth];
}