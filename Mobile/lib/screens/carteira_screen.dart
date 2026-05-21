import 'package:flutter/material.dart';
import 'package:mobile/services/getWalletDataService.dart';
import 'package:mobile/services/getWalletDataService.dart';

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
    print(data);
    setState(() {
      _walletData = data;
      _isLoading = false;
    });
  }

  Future<void> _mostrarDialogoAdicionarSaldo() async {
    final TextEditingController valorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 18, 25, 35),
          title: const Text("Adicionar Saldo", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Ex: 150.00",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixText: "R\$ ",
              prefixStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                // Tenta converter o texto digitado para número
                final double? valor = double.tryParse(valorController.text.replaceAll(',', '.'));

                if (valor != null && valor > 0) {
                  Navigator.pop(context); // Fecha o dialog

                  // Mostra o loading na tela principal
                  setState(() => _isLoading = true);

                  // Chama a cloud function
                  final sucesso = await _walletService.updateWallet(valor);

                  if (sucesso) {
                    // Recarrega os dados da carteira para atualizar o saldo na tela
                    await _loadWalletData();
                  } else {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erro ao adicionar saldo.")),
                    );
                  }
                }
              },
              child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patrimonio = _walletData?['wallet']['totalequity'] / 100 ?? '0,00';
    final saldo = _walletData?['wallet']['balanceCents'] / 100 ?? '0,00';
    final lucro = _walletData?['wallet']['totalProfitLoss'] / 100 ?? '0,00';
    final tokens = _walletData?['invested'] as List<dynamic>? ?? [];
    final historico = _walletData?['transactions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 20),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
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
                              _visivel ? 'R\$ $lucro' : '-', // Ajuste o sinal de + no backend ou aqui
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: lucro.toString().startsWith('-') ? Colors.red : Colors.green, // Cor dinâmica
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
                    // Iterando sobre a lista de tokens do JSON
                    if (tokens.isEmpty)
                      const Text("Nenhum token encontrado.", style: TextStyle(color: Colors.grey)),
                    ...tokens.map((token) {
                      return InkWell(
                        onLongPress: null,
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
                                const Icon(Icons.domain),
                                Expanded( // Usando Expanded para evitar overflow no texto
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
                                        "${(token['currentPriceCents'] / 100)  ?? '0,00'}/un",
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
                                      token['variacao'] ?? "+ 0.0%",
                                      style: TextStyle(
                                        fontSize: 12,
                                        // Cor dinâmica baseada no sinal da variação
                                        color: (token['variacao']?.toString().startsWith('-') ?? false)
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

              const Text(
                "Histórico",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              if (historico.isEmpty)
                const Text("Nenhuma transação recente.", style: TextStyle(color: Colors.grey)),

              ...historico.map((item) {
                // Verificação do tipo (ajuste a chave 'tipo' e o valor 'compra'/'deposito' conforme seu backend)
                final isCompra = item['type'] == 'compra';

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 25, 35), // Cor do card escuro
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // ÍCONE REDONDO
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // Fundo azul escuro para compra, verde escuro para depósito
                          color: isCompra
                              ? const Color.fromARGB(80, 43, 111, 244)
                              : const Color.fromARGB(80, 0, 150, 75),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCompra ? Icons.arrow_outward : Icons.south_west,
                          color: isCompra ? Colors.blueAccent : Colors.greenAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // TEXTOS (TÍTULO E DATA/DETALHES)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['type'] + " - " + item['startupName'] ?? 'Transação', // Ex: "Compra · Karpós S.A"
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date'].toString() ?? '', // Ex: "09/05/2026 · 100 tokens"
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // VALOR MONETÁRIO
                      Text(
                        isCompra
                            ? "-R\$ ${(item['priceCents']/100).toString()}"
                            : "+R\$ ${(item['priceCents']/100).toString()}",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          // Branco/Cinza para compra, Verde para depósito
                          color: isCompra ? Colors.white70 : Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 30), // Um respiro no final da tela
            ], // Fim do children da Column principal
          ),
        ),
      ),
    );
  }
}