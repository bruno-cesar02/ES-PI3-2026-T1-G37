/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import 'package:flutter/material.dart';
import 'package:mobile/screens/startup_details_page.dart';
import 'package:mobile/services/ListStartupService.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String? _digitado = "";
  String? _filtro = 'em_operacao';
  List<dynamic> _startups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    setState(() => _isLoading = true);
    ListStartupService().listStartups(stage: _filtro, search: _digitado).then((resultado) {
      if (mounted) {
        setState(() {
          _startups = resultado;
          _isLoading = false;
        });
      }
    }).catchError((e) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 12, 20),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Título ───────────────────────────────────────────────────────
            RichText(
              textWidthBasis: TextWidthBasis.longestLine,
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Encontre uma\n',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200, color: Colors.white),
                children: [
                  TextSpan(text: 'Startup para investir', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Busca e filtro ────────────────────────────────────────────────
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  TextField(
                    onChanged: (valor) {
                      setState(() => _digitado = valor);
                      _carregarDados();
                    },
                    decoration: InputDecoration(
                      prefixIcon: Image.asset('assets/images/search.png'),
                      hintText: 'Buscar startups',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.width * 0.04),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                  ),
                  PopupMenuButton<String?>(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onSelected: (String? valor) {
                      setState(() => _filtro = valor);
                      _carregarDados();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String?>(value: null, child: Text('Todos')),
                      const PopupMenuItem<String?>(value: 'em_operacao', child: Text('Em Operação')),
                      const PopupMenuItem<String?>(value: 'nova', child: Text('Nova')),
                      const PopupMenuItem<String?>(value: 'em_expansao', child: Text('Em Expansão')),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Lista de startups ─────────────────────────────────────────────
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 217, 217, 217),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _startups.isEmpty
                    ? const Center(child: Text('Startups não encontradas'))
                    : ListView.builder(
                  itemCount: _startups.length,
                  itemBuilder: (context, index) {
                    final startup = _startups[index];
                    return Card(
                      color: const Color.fromARGB(255, 194, 194, 194),
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        textColor: Colors.black,
                        leading: const Icon(Icons.business_outlined),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(startup['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text(startup['stage'] ?? ''),
                          ],
                        ),
                        subtitle: Text(
                          startup['shortDescription'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w300),
                        ),
                        // ── Ao clicar abre a tela de detalhes ────────
                        onTap: () {
                          final id = startup['id'] as String?;
                          if (id == null || id.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StartupDetailsPage(startupId: id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}