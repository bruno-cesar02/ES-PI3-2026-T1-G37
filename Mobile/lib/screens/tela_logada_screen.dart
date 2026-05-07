/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import 'package:flutter/material.dart';
import 'package:mobile/screens/catalogo_screen.dart';
import 'package:mobile/screens/tela_inicial_screen.dart';
import 'startup_details_page.dart';


//import 'carteira_screen.dart';
//import 'dashboard_screen.dart';
//import 'perfil_screen.dart';


class TelaLogadaScreen extends StatefulWidget{
  @override
  State<TelaLogadaScreen> createState() => _TelaLogadaScreenState();
}

class _TelaLogadaScreenState extends State<TelaLogadaScreen>{

  int _indice = 0;



// Preencha o _telas[]
  final List<Widget> _telas = [
    // Aba 0: Catálogo (Substituído temporariamente pelo seu botão de teste)
    Builder(
      builder: (context) => Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StartupDetailsPage(
                  startupId: 'biochip-campus', // Puxando do Firebase
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Testar Tela da Startup (BioChip)'),
        ),
      ),
    ),

    // Aba 1: Carteira (Mock temporário para não dar erro)
    const Center(child: Text('Carteira - Em breve')),

    // Aba 2: Dashboard (Mock temporário para não dar erro)
    const Center(child: Text('Dashboard - Em breve')),

    // Aba 3: Perfil (Mock temporário para não dar erro)
    const Center(child: Text('Perfil - Em breve')),
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