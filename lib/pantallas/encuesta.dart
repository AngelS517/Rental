import 'package:flutter/material.dart';
import 'pagina_principal.dart';
import 'pagina_agregar.dart';

class EncuestaPage extends StatelessWidget {
  const EncuestaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5FA),
      body: Column(
        children: [
          // Encabezado decorativo superior con degradado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF071082),
                  Color(0xFF7b43cd),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
              ),
            ),
            child: const Center(
              child: Text(
                'Rental',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF071082),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Elige la opción que deseas el día de hoy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          opcionEncuesta(
            context,
            'imagenes/necesito_vehiculo.png',
            'Necesito un vehículo',
            true,
          ),

          const SizedBox(height: 30),

          opcionEncuesta(
            context,
            'imagenes/ofrecer_vehiculo.png',
            'Quiero ofrecer mi vehículo',
            false,
          ),

          const Spacer(),

          // Pie decorativo inferior con degradado inverso
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7b43cd),
                    Color(0xFF071082),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget opcionEncuesta(BuildContext context, String imagePath, String texto, bool esPrimeraOpcion) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                esPrimeraOpcion ? const PaginaPrincipal() : const PaginaAgregar(),
          ),
        );
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF050272), // Color actualizado del botón
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 70,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto blanco para contraste
              ),
            ),
          ],
        ),
      ),
    );
  }
}
