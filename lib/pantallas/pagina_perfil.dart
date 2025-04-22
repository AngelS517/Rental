import 'package:flutter/material.dart';

class PaginaPerfil extends StatelessWidget {
  const PaginaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Esta es la página del perfil',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
