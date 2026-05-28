import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'carteira_screen.dart';
import 'balcao_screen.dart';// Import da tela do Balcão
import 'dashboard_screen.dart';

class TelaLogadaScreen extends StatefulWidget {
  const TelaLogadaScreen({super.key});

  @override
  State<TelaLogadaScreen> createState() => _TelaLogadaScreenState();
}

class _TelaLogadaScreenState extends State<TelaLogadaScreen> {
  int _indice = 0;

  // 1. LISTA DE TELAS (Exatamente 5 itens)
  final List<Widget> _telas = const [
    CatalogoScreen(),                         // Índice 0: Catálogo
    CarteiraScreen(),                         // Índice 1: Carteira
    BalcaoScreen(),                     // Índice 2: Balcão
    DashboardScreen(), // Índice 3: Dashboard
    Center(child: Text('Perfil - Em breve')),    // Índice 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O IndexedStack vai exibir a tela correspondente ao _indice
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

        // 2. LISTA DE BOTÕES (Exatamente 5 botões, mesma ordem de cima)
        destinations: [
          NavigationDestination(
              icon: Image.asset('assets/images/home.png', width: 30, height: 30),
              selectedIcon: Image.asset('assets/images/home.png', width: 30, height: 30),
              label: 'Catálogo' // Índice 0
          ),
          NavigationDestination(
              icon: Image.asset('assets/images/wallet.png', width: 30, height: 30),
              selectedIcon: Image.asset('assets/images/wallet.png', width: 30, height: 30),
              label: 'Carteira' // Índice 1
          ),
          const NavigationDestination(
              icon: Icon(Icons.swap_horiz, size: 30, color: Colors.black87),
              selectedIcon: Icon(Icons.swap_horiz, size: 30, color: Colors.black),
              label: 'Balcão' // Índice 2
          ),
          NavigationDestination(
              icon: Image.asset('assets/images/bar-chart.png', width: 30, height: 30),
              selectedIcon: Image.asset('assets/images/bar-chart.png', width: 30, height: 30),
              label: 'Dashboard' // Índice 3
          ),
          NavigationDestination(
              icon: Image.asset('assets/images/user.png', width: 30, height: 30),
              selectedIcon: Image.asset('assets/images/user.png', width: 30, height: 30),
              label: 'Perfil' // Índice 4
          ),
        ],
      ),
    );
  }
}