import 'package:flutter/material.dart';
import 'global.dart';
import 'pagina_perfil.dart'; // Asegúrate de importar esta página
import 'pagina_agregar.dart'; // Importa aquí tu página agregar

class PaginaPrincipalProveedor extends StatelessWidget {
  const PaginaPrincipalProveedor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: const Color(0xFF4B4EAB),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, tu propósito es: $propositoUsuarioGlobal',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaginaPerfil()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B4EAB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ir a perfil',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),

            /// 🔻 BOTÓN NUEVO: Ir a Agregar 🔻
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaginaAgregar(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B4EAB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ir a agregar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            /// 🔺 FIN BOTÓN NUEVO 🔺
          ],
        ),
      ),
    );
  }
}
