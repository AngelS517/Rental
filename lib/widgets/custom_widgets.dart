import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)], // Mismo color del AppBar
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedItemColor: Colors.white, // Ítem seleccionado resaltado
        unselectedItemColor: Colors.white60, // Ítems no seleccionados
        backgroundColor: Colors.transparent, // Fondo transparente para ver el gradiente
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'imagenes/inicio.png',
              height: 24,
              color: selectedIndex == 0 ? Colors.white : Colors.white60,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'imagenes/cercano.png',
              height: 24,
              color: selectedIndex == 1 ? Colors.white : Colors.white60,
            ),
            label: 'Cercanos',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'imagenes/alquilados.png',
              height: 24,
              color: selectedIndex == 2 ? Colors.white : Colors.white60,
            ),
            label: 'Alquilados',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'imagenes/perfil.png',
              height: 24,
              color: selectedIndex == 3 ? Colors.white : Colors.white60,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
