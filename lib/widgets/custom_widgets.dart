import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });
//NavBar
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      selectedItemColor: Colors.blue.shade900, // Color para ítem seleccionado
      unselectedItemColor: Colors.grey, // Color para ítems no seleccionados
      backgroundColor: Colors.white, // Fondo de la barra
      elevation: 8, // Sombra para mayor profundidad
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Mapa'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
      ],
    );
  }
}