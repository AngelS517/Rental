import 'package:flutter/material.dart';

class PaginaDos extends StatelessWidget {
  const PaginaDos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          '¡Bienvenida a la segunda página!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
