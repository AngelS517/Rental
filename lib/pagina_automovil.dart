import 'package:flutter/material.dart';

class PaginaAutomovil extends StatelessWidget {
  const PaginaAutomovil({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Esta es la página  de automoviles',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}