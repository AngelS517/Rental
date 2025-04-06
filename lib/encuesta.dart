import 'package:flutter/material.dart';
import 'pagina_inicio.dart';

class EncuestaPage extends StatelessWidget {
  const EncuestaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 100, color: Colors.white),
            const Text(
              'Rental',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            opcionEncuesta(context, Icons.vpn_key, 'Necesito un Vehículo'),
            const SizedBox(height: 20),
            opcionEncuesta(context, Icons.add_circle, 'Quiero ofrecer mi Vehículo'),
          ],
        ),
      ),
    );
  }

  Widget opcionEncuesta(BuildContext context, IconData icon, String texto) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaginaInicio()),
        );
      },
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.blue.shade900),
            const SizedBox(height: 10),
            Text(
              texto,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
