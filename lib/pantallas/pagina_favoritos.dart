import 'package:flutter/material.dart';

class PaginaFavoritos extends StatelessWidget {
  const PaginaFavoritos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Esta es la página de Favoritos',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
