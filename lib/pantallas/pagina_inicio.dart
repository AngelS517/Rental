import 'package:flutter/material.dart';
import 'pagina_principal.dart';
import 'pagina_mapa.dart';
import 'pagina_perfil.dart';
import 'pagina_favoritos.dart';

class PaginaInicio extends StatefulWidget {
  const PaginaInicio({super.key});

  @override
  _PaginaInicioState createState() => _PaginaInicioState();
}

class _PaginaInicioState extends State<PaginaInicio> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    PaginaPrincipal(),
    PaginaMapa(),
    PaginaPerfil(), 
    PaginaFavoritos(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Ubicacion'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }
}
