import 'package:flutter/material.dart';

class PaginaUno extends StatelessWidget {
  const PaginaUno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 40, errorBuilder: (context, error, stackTrace) {
              return const Text('Rental', style: TextStyle(fontSize: 22, color: Colors.white));
            }),
            const SizedBox(width: 10),
            const Text('Rental', style: TextStyle(fontSize: 22, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  categoriaItem(Icons.directions_car, 'Automóvil'),
                  categoriaItem(Icons.eco, 'Ecológico'),
                  categoriaItem(Icons.motorcycle, 'Moto'),
                  categoriaItem(Icons.pedal_bike, 'Bicicleta'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ofertas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ofertaItem('Chebrolet Kia', 'Dueño: Juan Sebastián', 'assets/carro1.png'),
              ofertaItem('Camioneta', 'Dueño: Ángel Santiago', 'assets/carro2.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoriaItem(IconData icon, String titulo) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.blue.shade900),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget ofertaItem(String titulo, String propietario, String imagen) {
    return Card(
      child: ListTile(
        leading: Image.asset(imagen, width: 50, height: 50, errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
        }),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(propietario),
        trailing: const Icon(Icons.local_offer, color: Colors.orange),
      ),
    );
  }
}
