import 'package:flutter/material.dart';
import 'package:rental/widgets/custom_widgets.dart';

class PaginaVehiculos extends StatefulWidget {
  const PaginaVehiculos({super.key});

  @override
  State<PaginaVehiculos> createState() => _PaginaVehiculosState();
}

class _PaginaVehiculosState extends State<PaginaVehiculos> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/inicio');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/mapa');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/perfil');
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, '/favoritos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Vehículos'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          vehiculoItem(
            'Chevrolet Spark',
            'Dueño: Juan Sebastián',
            'assets/carro1.png',
          ),
          vehiculoItem(
            'Mazda 3 Touring',
            'Dueño: Laura Gómez',
            'assets/carro2.png',
          ),
          vehiculoItem(
            'Toyota Corolla',
            'Dueño: Andrés Pérez',
            'assets/carro3.png',
          ),
          vehiculoItem(
            'Renault Logan',
            'Dueño: María Torres',
            'assets/carro4.png',
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget vehiculoItem(String titulo, String propietario, String imagen) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Image.asset(
          imagen,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_not_supported,
              size: 50,
              color: Colors.grey,
            );
          },
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(propietario),
        trailing: const Icon(Icons.local_offer, color: Colors.orange),
        onTap: () {
          // Aquí podrías navegar a detalles del vehículo si quieres
        },
      ),
    );
  }
}
