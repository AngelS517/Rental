import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: const Text('Lista de Automóviles'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('Categoria', isEqualTo: 'Automovil')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay automóviles disponibles.'));
          }

          final vehiculos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehiculos.length,
            itemBuilder: (context, index) {
              final data = vehiculos[index].data() as Map<String, dynamic>;
              return vehiculoItem(
                data['Marca'] ?? 'Sin marca',
                'Dueño: ${data['Dueño'] ?? 'Desconocido'}',
                data['Imagen'] ?? '',
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget vehiculoItem(String titulo, String propietario, String imagenUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagenUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey,
              );
            },
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(propietario),
        trailing: const Icon(Icons.local_offer, color: Colors.orange),
        onTap: () {
          // Aquí podrías navegar a los detalles del vehículo
        },
      ),
    );
  }
}
