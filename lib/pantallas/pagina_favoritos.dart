import 'package:flutter/material.dart';
import 'package:rental/widgets/custom_widgets.dart'; // Asegúrate de tener este import

class PaginaFavoritos extends StatefulWidget {
  const PaginaFavoritos({super.key});

  @override
  State<PaginaFavoritos> createState() => _PaginaFavoritosState();
}

class _PaginaFavoritosState extends State<PaginaFavoritos> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/inicio');
        break;
      case 1:
        Navigator.pushNamed(context, '/mapa');
        break;
      case 2:
        Navigator.pushNamed(context, '/favoritos');
        break;
      case 3:
        Navigator.pushNamed(context, '/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          'Esta es la página de Favoritos',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
