import 'package:flutter/material.dart';


class PaginaFavoritos extends StatefulWidget {
  const PaginaFavoritos({super.key});

  @override
  State<PaginaFavoritos> createState() => _PaginaFavoritosState();
}

class _PaginaFavoritosState extends State<PaginaFavoritos> {
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
    );
  }
}