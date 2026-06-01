/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/ 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/services/getWalletDataService.dart';
import 'package:mobile/screens/startup_detalhes_screen.dart';


final _money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

String _formatarData(dynamic raw) {
  if (raw is! Map) return '';
  final s = raw['_seconds'] ?? raw['seconds'];
  if (s is! num) return '';
  final d = DateTime.fromMillisecondsSinceEpoch(s.toInt() * 1000).toLocal();
  return DateFormat('dd/MM/yyyy · HH:mm').format(d);
}


Widget _startupLogo(String? url) {
  const double size = 48;
  final fallback = Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color.fromARGB(40, 217, 217, 217),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.domain, color: Colors.white70),
  );
  if (url == null || url.isEmpty) return fallback;
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      url,  
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}


class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  bool _visivel = true;
  bool _isLoading = true;
  Map<String, dynamic>? _walletData;

  final GetWalletDataService _walletService = GetWalletDataService();

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final data = await _walletService.fetchWalletDetails();
    setState(() {
      _walletData = data;
      _isLoading = false;
    });
  }

 
  Future<void> _mostrarDialogoAdicionarSaldo() async {
    String valorSelecionado = "500";
    final TextEditingController valorController = TextEditingController(text: "500");

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o teclado empurre a tela
      backgroundColor: Colors.transparent, // Fundo transparente para arredondar a borda
      builder: (BuildContext context) {
        // StatefulBuilder para gerenciar os cliques nos botões dentro do Modal
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              // Este padding faz o modal subir quando o teclado aparece
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pill/Traço superior para indicar que pode arrastar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const Text("Adicionar Saldo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020C14))),
                    const SizedBox(height: 4),
                    const Text("Simulação de depósito fictício", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 16),

                    // Botões de Atalho
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ["100", "500", "1000", "5000"].map((v) {
                        final isSelected = valorSelecionado == v;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              valorSelecionado = v;
                              valorController.text = v;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF386BF6) : const Color(0xFFF5F6F8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? const Color(0xFF386BF6) : Colors.transparent),
                            ),
                            child: Text(
                              "R\$ $v",
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF020C14),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Input Manual "Outro valor"
                    const Text("Outro valor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) {
                        setModalState(() => valorSelecionado = val);
                      },
                      style: const TextStyle(fontSize: 15, color: Color(0xFF020C14), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F6F8),
                        prefixText: "R\$ ",
                        prefixStyle: const TextStyle(color: Color(0xFF020C14), fontSize: 15, fontWeight: FontWeight.bold),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF386BF6), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF386BF6), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botão Confirmar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // O valor agora é pego em Reais (Ex: 100.50)
                          final double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));

                          if (valor != null && valor > 0) {
                            Navigator.pop(context);

                            setState(() => _isLoading = true);

                            // Manda para o Service (que vai converter para centavos)
                            final sucesso = await _walletService.updateWallet(valor);

                            if (sucesso) {
                              await _loadWalletData();
                            } else {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Erro ao adicionar saldo.")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF386BF6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0, // Design clean (flat)
                        ),
                        child: Text(
                          "Adicionar R\$ ${valorController.text.isEmpty ? '0' : valorController.text}",
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // ──────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wallet = _walletData?['wallet'] as Map?;

    // 2. Extrai os valores em centavos com fallback para 0 caso venham null da API
    final equityCents = wallet?['totalequity'] as num? ?? 0;
    final balanceCents = wallet?['balanceCents'] as num? ?? 0;
    final totalPL = wallet?['totalProfitLoss'] as num? ?? 0;
    final realizedPL = wallet?['realizedProfitLoss'] as num? ?? 0;

    // 3. Faz a divisão e já formata tudo no padrão String "0,00"
    final patrimonio = (equityCents / 100).toStringAsFixed(2).replaceAll('.', ',');
    final saldo = (balanceCents / 100).toStringAsFixed(2).replaceAll('.', ',');

    // Calcula o lucro separando a variável numérica para a verificação de cor depois
    final lucroNum = (totalPL + realizedPL) / 100;
    final String lucro = lucroNum.toStringAsFixed(2).replaceAll('.', ',');

    final tokens = (_walletData?['invested'] as List<dynamic>? ?? [])
        .where((token) => (token['quantity'] as num? ?? 0) > 0)
        .toList();

    final historico = _walletData?['transactions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 20),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
        color: Colors.blue,
        backgroundColor: const Color.fromARGB(255, 18, 25, 35),
        onRefresh: _loadWalletData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
            width: double.infinity,
            child: Column(
              spacing: 50,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    text: "Minha Carteira\n",
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 36),
                    children: [
                      TextSpan(
                        text: "Acompanhe seu saldo e tokens",
                        style: TextStyle(fontWeight: FontWeight.w200, fontSize: 16),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(123, 18, 56, 176),
                        Color.fromARGB(200, 43, 111, 244),
                        Color.fromARGB(123, 18, 56, 176),
                      ],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Patrimônio Total",
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              IconButton(
                                icon: Icon(
                                  _visivel ? Icons.remove_red_eye : Icons.question_mark_sharp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _visivel = !_visivel;
                                  });
                                },
                              ),
                            ],
                          ),
                          Text(
                            _visivel ? 'R\$ $patrimonio' : '-',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 26,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            spacing: 6,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Saldo disponível',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                _visivel ? 'R\$ $saldo' : '-',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                            child: VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                          Column(
                            spacing: 6,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lucro/Prejuízo',
                                style: TextStyle(fontWeight: FontWeight.w300),
                              ),
                              Text(
                                _visivel ? 'R\$ $lucro' : '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: lucro.toString().startsWith('-') ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: _mostrarDialogoAdicionarSaldo,
                            style: ButtonStyle(
                              padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color.fromARGB(123, 217, 217, 217)),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                  side: const BorderSide(
                                    style: BorderStyle.solid,
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10))),
                            ),
                            child: const SizedBox(
                              width: 130,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.white),
                                  Text(
                                    "Adicionar Saldo",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => null,
                            style: ButtonStyle(
                              padding: const WidgetStatePropertyAll(EdgeInsets.all(15)),
                              backgroundColor: const WidgetStatePropertyAll(
                                  Color.fromARGB(255, 43, 111, 244)),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                            ),
                            child: const SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Investir",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Icon(Icons.auto_graph, color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  clipBehavior: Clip.hardEdge,
                  width: double.infinity,
                  decoration: const BoxDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      const Text(
                        "Tokens",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                      ),
                      if (tokens.isEmpty)
                        const Text("Nenhum token ativo no momento.", style: TextStyle(color: Colors.grey)),
                      ...tokens.map((token) {
                        return InkWell(
                          onLongPress: null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StartupDetailsPage(
                                  startupId: token['startupId'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(40, 217, 217, 217),
                                border: Border.all(color: Colors.grey, width: 0.5),
                                borderRadius: const BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Row(
                                spacing: 20,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _startupLogo((token['coverImageUrl'] ?? token['logoUrl'] ?? token['logo'])?.toString()),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          token['startupName'] ?? "Empresa S.A",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 20),
                                        ),
                                        Text(
                                          "${token['quantity'] ?? 0} tokens",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          "${(token['currentPriceCents'] / 100) ?? '0,00'}/un",
                                          style: const TextStyle(color: Colors.grey, overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "R\$ ${token['totalPriceCents'] / 100 ?? '0,00'}",
                                        style: const TextStyle(
                                            fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        ((token['currentPriceCents'] - token['averagePurchasePriceCents']) / 100).toString() + "%" ?? "+ 0.0%",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: (((token['currentPriceCents'] - token['averagePurchasePriceCents']) / 100)< 0)
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white)
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    const Text(
                      "Histórico",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    if (historico.isEmpty)
                      const Text("Nenhuma transação recente.", style: TextStyle(color: Colors.grey)),
                    ...historico.map((item) => _TransacaoTile(item)),
                  ],
                ),
                // ──────────────────────────────────────────────────────────

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// card de uma transação do histórico 
class _TransacaoTile extends StatelessWidget {
  final Map<dynamic, dynamic> item; 
  const _TransacaoTile(this.item);

  @override
  Widget build(BuildContext context) {
    final tipoRaw = (item['type'] ?? '').toString().toLowerCase();
    final nome = item['startupName']?.toString();

    // Normaliza o tipo: compra | venda | deposito | saque.
    // Mantém compatibilidade com dados antigos (depósito gravado
    // como 'compra' + 'Saldo da Carteira').
    final String tipo;
    if (tipoRaw == 'deposito' || (tipoRaw == 'compra' && nome == 'Saldo da Carteira')) {
      tipo = 'deposito';
    } else if (tipoRaw == 'saque') {
      tipo = 'saque';
    } else if (tipoRaw == 'venda') {
      tipo = 'venda';
    } else {
      tipo = 'compra';
    }

    final entrada = tipo == 'deposito' || tipo == 'venda'; // dinheiro entrando = verde

    final qtd = (item['quantity'] as num?) ?? (item['tokens'] as num?);
    final precoUnitCents = (item['priceCents'] as num?) ?? 0;
    // priceCents é o preço POR UNIDADE; o total gasto/recebido = qtd × preço.
    // Em depósito/saque a qtd é 1, então o valor cheio continua certo.
    final reais = (precoUnitCents * (qtd ?? 1)).abs() / 100;
    final data = _formatarData(item['date']);

    final titulo = switch (tipo) {
      'deposito' => 'Depósito de saldo',
      'saque' => 'Saque',
      'venda' => 'Venda · ${nome ?? ''}',
      _ => 'Compra · ${nome ?? ''}',
    };
    final ehToken = tipo == 'compra' || tipo == 'venda'; // depósito/saque não têm tokens
    final subtitulo = (ehToken && qtd != null && qtd > 0) ? '$data · ${qtd.toInt()} tokens' : data;

    final cor = entrada ? const Color(0xFF00AE51) : const Color(0xFF386BF6);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(13, 255, 255, 255),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cor.withValues(alpha: 0.15),
            child: Icon(entrada ? Icons.south_west : Icons.north_east, color: cor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitulo, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${entrada ? '+' : '-'}${_money.format(reais)}',
            style: TextStyle(
              color: entrada ? cor : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}