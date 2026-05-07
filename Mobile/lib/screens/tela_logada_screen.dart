/*
Nome: Otávio Augusto Antunes Marquez
RA: 24025832
*/

import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class TelaLogadaScreen extends StatefulWidget {
  const TelaLogadaScreen({super.key});

  @override
  State<TelaLogadaScreen> createState() => _TelaLogadaScreenState();
}

class _TelaLogadaScreenState extends State<TelaLogadaScreen> {
  int _indice = 0;

  final List<Widget> _telas = const [
    CatalogoScreen(),
    Center(child: Text('Carteira - Em breve')),
    Center(child: Text('Dashboard - Em breve')),
    Center(child: Text('Perfil - Em breve')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: const Color.fromARGB(80, 43, 111, 244),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        selectedIndex: _indice,
        onDestinationSelected: (int novoIndice) => setState(() => _indice = novoIndice),
        destinations: [
          NavigationDestination(icon: Image.asset('assets/images/home.png', width: 30, height: 30), selectedIcon: Image.asset('assets/images/home.png', width: 30, height: 30), label: 'Catalogo'),
          NavigationDestination(icon: Image.asset('assets/images/wallet.png', width: 30, height: 30), selectedIcon: Image.asset('assets/images/wallet.png', width: 30, height: 30), label: 'Carteira'),
          NavigationDestination(icon: Image.asset('assets/images/bar-chart.png', width: 30, height: 30), selectedIcon: Image.asset('assets/images/bar-chart.png', width: 30, height: 30), label: 'Dashboard'),
          NavigationDestination(icon: Image.asset('assets/images/user.png', width: 30, height: 30), selectedIcon: Image.asset('assets/images/user.png', width: 30, height: 30), label: 'Perfil'),
        ],
      ),
    );
  }
}