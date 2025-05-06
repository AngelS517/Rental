import 'package:flutter/material.dart';
import 'package:rental/widgets/custom_widgets.dart';
import 'pagina_automoviles.dart'; 

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _selectedIndex = 0; // Índice para "Inicio"

  void _onItemTapped(int index) {
    if (index == 0) {
      // No hace nada, ya estamos en Inicio
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mapa');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/perfil');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/favoritos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80), // Espacio para el AppBar
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
                children: [
                  categoriaItem(context, 'imagenes/auto.png', 'Automóvil', true),
                  categoriaItem(context, 'imagenes/minivan.png', 'Minivan', false),
                  categoriaItem(context, 'imagenes/moto.png', 'Moto', false),
                  categoriaItem(context, 'imagenes/electricos.png', 'Electricos', false),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ofertas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ofertaItem('Chevrolet Kia', 'Dueño: Juan Sebastián', 'assets/carro1.png'),
              ofertaItem('Camioneta', 'Dueño: Ángel Santiago', 'assets/carro2.png'),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'imagenes/logorental.png',
            height: 40,
            errorBuilder: (context, error, stackTrace) {
              return const Text(
                'Rental',
                style: TextStyle(fontSize: 22, color: Colors.black),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget categoriaItem(BuildContext context, String imagenPath, String titulo, bool esAutomovil) {
    return GestureDetector(
      onTap: () {
        if (esAutomovil) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaginaVehiculos()),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050272), // Color azul oscuro #050272
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagenPath, height: 50),
            const SizedBox(height: 10),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget ofertaItem(String titulo, String propietario, String imagen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.asset(
          imagen,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
          },
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(propietario),
        trailing: const Icon(Icons.local_offer, color: Colors.orange),
      ),
    );
  }
}