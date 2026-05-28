import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();

  String selectedPeriod = '1M';
  String? selectedStartupId;

  bool _isLoading = true;
  bool _isChartLoading = false;

  final Color bgColor = const Color(0xFF020C14);
  final Color primaryColor = const Color(0xFF386BF6);
  final Color positiveColor = const Color(0xFF00AE51);
  final Color negativeColor = const Color(0xFFEF4444);

  // Variáveis de Estado
  String _nomeUsuario = '';
  double _patrimonioTotal = 0;
  double _variacaoTotal = 0;
  List<FlSpot> _generalSpots = [];
  List<Map<String, dynamic>> _portfolio = [];
  List<FlSpot> _startupSpots = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // ─── COMUNICAÇÃO COM O SERVICE ───

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Busca o nome do usuário primeiro
    final nome = await _dashboardService.fetchUserName();
    if (mounted) setState(() => _nomeUsuario = nome);

    // Depois busca os dados gerais
    await _fetchGeneralDashboard();
  }

  Future<void> _fetchGeneralDashboard() async {
    try {
      final data = await _dashboardService.fetchGeneralDashboard(selectedPeriod);

      _patrimonioTotal = (data['patrimonioTotalCents'] ?? 0) / 100.0;
      _variacaoTotal = (data['variacaoTotalPercent'] ?? 0).toDouble();

      final List rawHistory = data['chartHistoryCents'] ?? [];
      _generalSpots = rawHistory.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value as num) / 100.0)).toList();

      final List rawPortfolio = data['portfolio'] ?? [];
      _portfolio = rawPortfolio.map((e) => Map<String, dynamic>.from(e)).toList();

    } catch (e) {
      debugPrint("Erro ao buscar dashboard geral: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchStartupHistory(String startupId) async {
    setState(() => _isChartLoading = true);
    try {
      final data = await _dashboardService.fetchStartupHistory(startupId, selectedPeriod);
      final List hist = data['history'] ?? [];

      _startupSpots = [];
      if (hist.isEmpty) {
        final currentPrice = (data['currentPriceCents'] ?? 0) / 100.0;
        for (int i = 0; i <= 6; i++) {
          _startupSpots.add(FlSpot(i.toDouble(), currentPrice));
        }
      } else {
        for (int i = 0; i < hist.length; i++) {
          double xPos = hist.length == 1 ? 6.0 : (i / (hist.length - 1)) * 6.0;
          double yPos = (hist[i]['priceCents'] as num) / 100.0;
          _startupSpots.add(FlSpot(xPos, yPos));
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar histórico da startup: $e");
    } finally {
      if (mounted) setState(() => _isChartLoading = false);
    }
  }

  // ─── GETTERS DINÂMICOS ───

  List<FlSpot> get currentChartData => selectedStartupId == null ? _generalSpots : _startupSpots;

  String get topTitle => selectedStartupId == null
      ? 'Patrimônio Total'
      : 'Seus tokens em ${_portfolio.firstWhere((p) => p['id'] == selectedStartupId)['nome']}';

  double get topValue {
    if (selectedStartupId == null) return _patrimonioTotal;
    return (_portfolio.firstWhere((p) => p['id'] == selectedStartupId)['valorTotalCents'] as num) / 100.0;
  }

  double get topVariation {
    if (selectedStartupId == null) return _variacaoTotal;
    return (_portfolio.firstWhere((p) => p['id'] == selectedStartupId)['variacaoPercent'] as num).toDouble();
  }

  double get chartMinY {
    if (currentChartData.isEmpty) return 0;
    final minVal = currentChartData.map((s) => s.y).reduce(min);
    return minVal > 0 ? minVal * 0.95 : 0;
  }

  double get chartMaxY {
    if (currentChartData.isEmpty) return 100;
    final maxVal = currentChartData.map((s) => s.y).reduce(max);
    return maxVal > 0 ? maxVal * 1.05 : 100;
  }

  // ─── UI BUILDER ───
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(backgroundColor: bgColor, body: const Center(child: CircularProgressIndicator(color: Color(0xFF386BF6))));
    }

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
                  Text(_nomeUsuario, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Visão Dinâmica (Patrimônio)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topTitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_formatBRL(topValue), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: topVariation >= 0 ? positiveColor.withOpacity(0.15) : negativeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(100)
                        ),
                        child: Text(
                            '${topVariation >= 0 ? '+' : ''}${topVariation.toStringAsFixed(2)}%',
                            style: TextStyle(color: topVariation >= 0 ? positiveColor : negativeColor, fontSize: 13, fontWeight: FontWeight.bold)
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
                    onTap: () {
                      setState(() => selectedPeriod = period);
                      if (selectedStartupId == null) {
                        setState(() => _isChartLoading = true);
                        _fetchGeneralDashboard().then((_) {
                          if (mounted) setState(() => _isChartLoading = false);
                        });
                      } else {
                        _fetchStartupHistory(selectedStartupId!);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isSelected ? primaryColor : Colors.transparent, width: 2))),
                      child: Text(period, style: TextStyle(color: isSelected ? primaryColor : const Color(0xFF718096), fontWeight: FontWeight.bold, fontSize: 13)),
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
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                child: _isChartLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF386BF6)))
                    : Column(
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
                                showTitles: true, reservedSize: 22, interval: 1,
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
                                showTitles: true, reservedSize: 32,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.min || value == meta.max) return const SizedBox.shrink();
                                  return Text('R\$${value.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF555555), fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0, maxX: 6,
                          minY: chartMinY, maxY: chartMaxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: currentChartData,
                              isCurved: true, color: primaryColor, barWidth: 2, isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) => CircleButtPainter(
                                  color: const Color(0xFF1A1F26), strokeWidth: 1.5, strokeColor: primaryColor, radius: 3.5,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [primaryColor.withOpacity(0.3), primaryColor.withOpacity(0.02)],
                                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista Inferior "Seus Tokens"
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
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
                              onTap: () => setState(() {
                                selectedStartupId = null;
                                _fetchGeneralDashboard();
                              }),
                              child: const Text('Limpar seleção', style: TextStyle(color: Color(0xFF386BF6), fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _portfolio.isEmpty
                          ? const Center(child: Text('Você não possui tokens.', style: TextStyle(color: Colors.grey)))
                          : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _portfolio.length,
                        separatorBuilder: (context, index) => const Divider(color: Color(0xFFF0F0F0), height: 1),
                        itemBuilder: (context, index) {
                          final item = _portfolio[index];
                          final isSelected = selectedStartupId == item['id'];
                          final valCents = item['valorTotalCents'] as num;
                          final variacao = (item['variacaoPercent'] as num).toDouble();
                          final bool isPositive = variacao >= 0;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedStartupId = null;
                                } else {
                                  selectedStartupId = item['id'];
                                  _fetchStartupHistory(selectedStartupId!);
                                }
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
                                    decoration: BoxDecoration(color: const Color(0xFF020C14), borderRadius: BorderRadius.circular(14)),
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
                                      Text(_formatBRL(valCents / 100.0), style: const TextStyle(color: Color(0xFF020C14), fontSize: 16, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${isPositive ? '+' : ''}${variacao.toStringAsFixed(1)}%',
                                          style: TextStyle(color: isPositive ? positiveColor : negativeColor, fontSize: 13, fontWeight: FontWeight.w600)
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

class CircleButtPainter extends FlDotPainter {
  final Color color;
  final double radius;
  final Color strokeColor;
  final double strokeWidth;

  CircleButtPainter({required this.color, required this.radius, required this.strokeColor, required this.strokeWidth});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offsetInCanvas) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final strokePaint = Paint()..color = strokeColor..style = PaintingStyle.stroke..strokeWidth = strokeWidth;
    canvas.drawCircle(offsetInCanvas, radius, paint);
    canvas.drawCircle(offsetInCanvas, radius, strokePaint);
  }

  @override
  Size getSize(FlSpot spot) => Size(radius * 2, radius * 2);

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

  @override
  List<Object?> get props => [color, radius, strokeColor, strokeWidth];
}