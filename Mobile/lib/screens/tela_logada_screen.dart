/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import 'package:flutter/material.dart';
import 'package:mobile/screens/tela_inicial_screen.dart';


class TelaLogadaScreen extends StatefulWidget{
  @override
  State<TelaLogadaScreen> createState() => _TelaLogadaScreenState();
}

class _TelaLogadaScreenState extends State<TelaLogadaScreen>{

  int _indice = 0;

  final List<Widget> _telas = [
    /*
    Adicionar todas as telas aqui, tem que dar 4 certinho, se faltar alguma repita a tela

    CASO NAO TIVER 4 TELAS AQUI, VAI DAR TELA VERMELHA EM ALGM MOMENTO

    const tela();
    const tela();
    const tela();
    cont tela();

    */
  ];

  @override
  Widget build(BuildContext context) => Scaffold(


    body: _telas[_indice],

    bottomNavigationBar: NavigationBar(

      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,

      indicatorColor: Color.fromARGB(80, 43, 111, 244),

      labelTextStyle: WidgetStatePropertyAll(TextStyle(
        color: Colors.black,
        fontWeight: FontWeight(500),
      )),

      backgroundColor: Colors.white,

      selectedIndex: _indice,

      onDestinationSelected: (int novoIndice){
        setState(() {
          _indice = novoIndice;
        });
      },

    destinations: [
      NavigationDestination(
          icon: Image.asset(
              'assets/images/home.png',
            width: 30,
            height: 30,
          ),
          selectedIcon: Image.asset(
            'assets/images/home.png',
            width: 30,
            height: 30,
          ),
          label: 'Catalogo'),
      NavigationDestination(
          icon: Image.asset(
            'assets/images/wallet.png',
            width: 30,
            height: 30,
          ),
          selectedIcon: Image.asset(
            'assets/images/wallet.png',
            width: 30,
            height: 30,
          ),
          label: 'Carteira'),
      NavigationDestination(
          icon: Image.asset(
            'assets/images/bar-chart.png',
            width: 30,
            height: 30,
          ),
          selectedIcon: Image.asset(
              'assets/images/bar-chart.png',
            height: 30,
            width: 30,
          ),
          label: 'Dashboard'),
      NavigationDestination(
          icon: Image.asset(
            'assets/images/user.png',
            width: 30,
            height: 30,
          ),
          selectedIcon: Image.asset(
            'assets/images/user.png',
            width: 30,
            height: 30,
          ),
          label: 'Perfil')
    ],
    ),


  );
}