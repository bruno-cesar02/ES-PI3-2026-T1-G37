/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import 'dart:typed_data';

import 'package:mobile/services/ListStartupService.dart';
import 'package:mobile/widgets/startupcard.dart';

import '../config/firebase_setup.dart';
import 'package:flutter/material.dart';


class CatalogoScreen extends StatefulWidget{
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen>{

  String? _digitado = "";
  String? _filtro = "em_operacao";
  List<dynamic> _startups = [];
  bool _isLoading = false;

  void _carregarDados(){
    ListStartupService list = ListStartupService();
    list.listStartups(stage: _filtro, search: _digitado).then((resultado) {
      setState(() {
        _startups = resultado;
        print(_startups);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    ListStartupService list = ListStartupService();
    list.listStartups(stage: _filtro, search: _digitado).then((resultado) {
      setState(() {
        _startups = resultado;
        print(_startups);
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Color.fromARGB(255, 2, 12, 20),
    body: Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.1
      ),
      width: double.infinity,
      child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 40,
      children: [
        RichText(
          textWidthBasis: TextWidthBasis.longestLine,
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Encontre uma\n',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight(200),
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'Startup para investir',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight(800),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              TextField(
                onChanged: (valor){
                  setState(() {
                    _digitado = valor;
                    _carregarDados();
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Image.asset(
                      'assets/images/search.png',
                  ),
                  hint: Text(
                    'Buscar startups',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: MediaQuery.of(context).size.width * 0.04
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  )
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.filter_list), // Ícone do botão
                onSelected: (String valor) {
                  setState(() {
                    _filtro = valor; // Sua variável global de filtro
                  });
                  _carregarDados(); // Chama a função que busca no Firebase
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'em_operacao',
                    child: Text('Em Operação'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'nova',
                    child: Text('Nova'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'em_expansao',
                    child: Text('Em Expansão'),
                  ),
                ],
              ),
            ],
          ),
        ),


        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Color.fromARGB(255,217,217,217),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: _startups.isEmpty 
              ? const Padding(
              padding: EdgeInsets.all(0),
              child: Center(
                child: Text("Startups não encontradas")
              ),
          )
          : ListView.builder(
                itemCount: _startups.length,

                  itemBuilder: (context, index){
                    final startup = _startups[index];

                    return Card(
                      color: Color.fromARGB(255, 194, 194, 194),
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        
                        textColor: Colors.black,
                        leading: const Icon(Icons.business_outlined),
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(startup["name"],
                          style: TextStyle(
                            fontWeight: FontWeight(800)
                          ),
                        ),Text(startup["stage"])]
                        ),
                        subtitle: Text(startup["shortDescription"],
                          style: TextStyle(
                            fontWeight: FontWeight(300)
                          ),
                        ),
                      ),
                    );
                  }
              ),
          ),
        ),
      ],
    ),
    ),
  );
}